from typing import List
from fastapi import HTTPException
from datetime import datetime
import asyncio

from backend.database.sql_models import Appointment, Medic, User
from backend.utils.encryption_utils import encrypt_data, encrypt_fields, decrypt_fields
from .appointment_repository import AppointmentRepository
from .appointment_schemas import AppointmentCreateSchema, AppointmentOutSchema
from backend.features.medical_service.medical_service_service import MedicalServiceService
from backend.features.appointments.scheduling.scheduling_service import SchedulingService

class AppointmentService:
    def __init__(self, appointment_repo: AppointmentRepository, scheduling_service: SchedulingService, medical_service_service: MedicalServiceService):
        self._appointment_repo = appointment_repo
        self._scheduling_service = scheduling_service
        self._medical_service_service = medical_service_service

    async def _ensure_medic_owns_appointment(self, medic_id, appointment_id: int):  
        appointment = await self._appointment_repo.get_appointment_by_id(appointment_id)
        if not appointment:
            raise HTTPException(status_code=404, detail="Appointment not found")
        if appointment.medic_id != medic_id:
            raise HTTPException(status_code=403, detail="Not authorized to cancel this appointment")

    async def _ensure_user_has_appointment(self, user_id: int, appointment_id: int):
        appointment = await self._appointment_repo.get_appointment_by_id(appointment_id)
        if not appointment:
            raise HTTPException(status_code=404, detail="Appointment not found")
        if appointment.user_id != user_id:
            raise HTTPException(status_code=403, detail="Not authorized to cancel this appointment")

    async def _get_appointment_by_id(self, appointment_id: int) -> AppointmentOutSchema:
        encrypted_appointment = await self._appointment_repo.get_appointment_by_id(appointment_id)
        decrypted_fields = decrypt_fields(encrypted_appointment, ["address", "medical_service_name", "medical_service_price", "appointment_start", "appointment_end", "appointment_status"])

        return AppointmentOutSchema(
            id=appointment_id,
            user_id=encrypted_appointment.user_id,
            medic_id=encrypted_appointment.medic_id,
            medical_service_id=encrypted_appointment.medical_service_id,

            medical_service_name=decrypted_fields["medical_service_name"],
            medical_service_price=int(decrypted_fields["medical_service_price"]),
            
            address=decrypted_fields["address"],
            appointment_start=decrypted_fields["appointment_start"],
            appointment_end=decrypted_fields["appointment_end"],
            appointment_status=decrypted_fields["appointment_status"],
            created_at=encrypted_appointment.created_at,
            updated_at=encrypted_appointment.updated_at,
        )

    async def get_user_appointments(self, user_id: int) -> List[AppointmentOutSchema]:
        encrypted_user_appointments = await self._appointment_repo.get_user_appointments(user_id)
        return await asyncio.gather(
            *[self._get_appointment_by_id(appointment.id) for appointment in encrypted_user_appointments]
        )

    async def get_medic_appointments(self, medic_id: int) -> List[AppointmentOutSchema]:
        encrypted_medic_appointments = await self._appointment_repo.get_medic_appointments(medic_id)
        return await asyncio.gather(
            *[self._get_appointment_by_id(appointment.id) for appointment in encrypted_medic_appointments]
        )

    async def create_appointment(self, user_id: int, appointment_payload: AppointmentCreateSchema) -> AppointmentOutSchema:
        medical_service = await self._medical_service_service.get_medical_service_by_id(appointment_payload.medical_service_id)

        if not medical_service:
            raise HTTPException(404, detail="Medical Service not found")
        
        #TODO: Maybe I need to drop the try catch
        try:
            date_start = appointment_payload.appointment_start
            date_end = appointment_payload.appointment_end
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid datetime format")
        
        target_date = date_start.date()
        free_slot_models = await self._scheduling_service.get_free_time_slots_for_a_day(appointment_payload.medic_id, target_date, medical_service.duration_minutes)
        free_slots = [(slot.start, slot.end) for slot in free_slot_models]

        requested_slot = (
            f"{date_start.hour:02d}:{date_start.minute:02d}",
            f"{date_end.hour:02d}:{date_end.minute:02d}"
        )

        print(f"[DEBUG] Comparing against raw slots: {free_slots}")
        print(f"[DEBUG] Requested slot: {requested_slot}")

        if requested_slot not in free_slots:
            raise HTTPException(status_code=409, detail="Unavailable time slot")
        
        encrypted_appointment_fields = encrypt_fields({
            "address":           appointment_payload.address,
            "appointment_start": appointment_payload.appointment_start.isoformat(),
            "appointment_end":   appointment_payload.appointment_end.isoformat(),
            "appointment_status": "pending"
        }, ["address", "appointment_start", "appointment_end", "appointment_status"])

        appointment: Appointment = await self._appointment_repo.create_user_appointment(
            user_id = user_id,
            medic_id = appointment_payload.medic_id,
            medical_service_id = appointment_payload.medical_service_id,
            address = encrypted_appointment_fields["address"],
            appointment_start = encrypted_appointment_fields["appointment_start"],
            appointment_end = encrypted_appointment_fields["appointment_end"],
            appointment_status = encrypted_appointment_fields["appointment_status"],
            medical_service_name = encrypt_data(medical_service.name),
            medical_service_price = encrypt_data(str(medical_service.price)),
        )

        return await self._get_appointment_by_id(appointment.id)

    async def change_appointment_status(self, current_account, appointment_id: int, new_appointment_status: str):
        appointment = await self._appointment_repo.get_appointment_by_id(appointment_id)
        if not appointment:
            raise HTTPException(404, detail="Appointment not found")
        
        if isinstance(current_account, Medic):
            if appointment.medic_id != current_account.id:
                raise HTTPException(403, "Not permitted to change this appointment")
        else:
            if appointment.user_id != current_account.id:
                raise HTTPException(403, "Not permitted to change this appointment")

        encrypted_new_status = encrypt_data(new_appointment_status)
        await self._appointment_repo.update_appointment(appointment_id, {"appointment_status": encrypted_new_status})

        return await self._get_appointment_by_id(appointment_id)

    async def accept_appointment(self, current_medic: Medic, appointment_id: int):
        await self._ensure_medic_owns_appointment(current_medic.id, appointment_id)
        
        return await self.change_appointment_status(current_medic, appointment_id, "accepted")

    async def reject_appointment(self, current_medic: Medic, appointment_id: int):
        await self._ensure_medic_owns_appointment(current_medic.id, appointment_id)

        return await self.change_appointment_status(current_medic, appointment_id, "rejected")

    async def complete_appointment(self, current_medic: Medic, appointment_id: int):
        await self._ensure_medic_owns_appointment(current_medic.id, appointment_id)

        return await self.change_appointment_status(current_medic, appointment_id, "completed")

    async def cancel_user_appointment(self, current_user: User, appointment_id: int) -> None:
        await self._ensure_user_has_appointment(current_user.id, appointment_id)

        return await self.change_appointment_status(current_user, appointment_id, "canceled")

    async def cancel_medic_appointment(self, current_medic: Medic, appointment_id: int) -> None:
        await self._ensure_medic_owns_appointment(current_medic.id, appointment_id)

        return await self.change_appointment_status(current_medic, appointment_id, "canceled")
    