import asyncio
from typing import List, Union

from fastapi import HTTPException

from backend.config import ENCRYPTED_APPOINTMENT_FIELDS
from backend.core.database.sql_models import Medic, User
from backend.features.appointments.core.appointment_repository import AppointmentRepository
from backend.core.utils.encryption_utils import encrypt_data, encrypt_fields, decrypt_fields
from backend.features.appointments.scheduling.scheduling_service import SchedulingService
from backend.features.medical_service.medical_service_service import MedicalServiceService
from backend.features.medics.medic_repository import MedicRepository
from backend.features.medics.medic_service import MedicService
from backend.features.users.user_service import UserService
from .appointment_schemas import AppointmentCreateSchema, AppointmentOutSchema


class AppointmentService:
    def __init__(self, appointment_repository: AppointmentRepository, medic_repository: MedicRepository, scheduling_service: SchedulingService, medical_service_service: MedicalServiceService, user_service: UserService, medic_service: MedicService):
        self._appointment_repository = appointment_repository
        self._medic_repository = medic_repository
        self._scheduling_service=scheduling_service
        self._medical_service=medical_service_service
        self._user_service = user_service
        self._medic_service = medic_service

    async def _ensure_medic_owns_appointment(self, medic_id: int, appointment_id: int) -> None:
        appointment_record = await self._appointment_repository.get_by_id(appointment_id)
        
        if not appointment_record:
            print(f"[ERROR] Appointment {appointment_id} not found")
            raise HTTPException(404, "Appointment not found")
        
        if appointment_record.medic_id!=medic_id:
            print(f"[WARNING] Medic {medic_id} unauthorized for appointment {appointment_id}")
            raise HTTPException(403, "Not authorized")

    async def _ensure_user_owns_appointment(self, user_id: int, appointment_id: int) -> None:
        appointment_record = await self._appointment_repository.get_by_id(appointment_id)
        
        if not appointment_record:
            print(f"[ERROR] Appointment {appointment_id} not found")
            raise HTTPException(404, "Appointment not found")
        
        if appointment_record.user_id!=user_id:
            print(f"[WARNING] User {user_id} unauthorized for appointment {appointment_id}")
            raise HTTPException(403, "Not authorized")

    async def _map_appointment_to_schema(self, appointment_id: int) -> AppointmentOutSchema:
        appointment_record = await self._appointment_repository.get_by_id(appointment_id)
        
        if not appointment_record:
            raise HTTPException(404, "Appointment not found")

        decrypted_values = decrypt_fields(appointment_record, ENCRYPTED_APPOINTMENT_FIELDS)
        
        return AppointmentOutSchema(
            id=appointment_record.id,
            user_id=appointment_record.user_id,
            medic_id=appointment_record.medic_id,
            patient=await self._user_service.get_user_by_id(appointment_record.user_id),
            medic=await self._medic_service.get_medic_by_id(appointment_record.medic_id),
            medical_service_id=appointment_record.medical_service_id,
            medical_service_name=decrypted_values["medical_service_name"],
            medical_service_price=int(decrypted_values["medical_service_price"]),
            address=decrypted_values["address"],
            appointment_start=decrypted_values["appointment_start"],
            appointment_end=decrypted_values["appointment_end"],
            appointment_status=decrypted_values["appointment_status"],
            created_at=appointment_record.created_at,
            updated_at=appointment_record.updated_at,
        )

    async def get_user_appointments(self, user_id: int) -> List[AppointmentOutSchema]:
        appointment_records = await self._appointment_repository.get_user_appointments(user_id)

        results: List[AppointmentOutSchema] = []
        for rec in appointment_records:
            results.append(await self._map_appointment_to_schema(rec.id))
        return results

    async def get_medic_appointments(self, medic_id: int) -> List[AppointmentOutSchema]:
        appointment_records = await self._appointment_repository.get_medic_appointments(medic_id)

        results: List[AppointmentOutSchema] = []
        for rec in appointment_records:
            results.append(await self._map_appointment_to_schema(rec.id))
        return results

    async def create_appointment(self, user_id: int, appointment_payload: AppointmentCreateSchema) -> AppointmentOutSchema:
        print(f"[INFO] Creating appointment for user_id={user_id}, medic_id={appointment_payload.medic_id}, medical_service_id={appointment_payload.medical_service_id}")

        medical_service = await self._medical_service.get_medical_service_by_id(appointment_payload.medical_service_id)
        if not medical_service:
            print(f"[ERROR] Medical service {appointment_payload.medical_service_id} not found")
            raise HTTPException(404, "Medical Service not found")
        
        medic_entity = await self._medic_repository.get_medic_by_id(appointment_payload.medic_id)

        appointment_start = appointment_payload.appointment_start
        appointment_end = appointment_payload.appointment_end
        target_date = appointment_start.date()

        available_slots_models=await self._scheduling_service.get_free_time_slots_for_a_day(
            appointment_payload.medic_id, target_date, medical_service.duration_minutes
        )
        available_slots={(slot.start, slot.end) for slot in available_slots_models}
        requested_slot=(f"{appointment_start.hour:02d}:{appointment_start.minute:02d}", f"{appointment_end.hour:02d}:{appointment_end.minute:02d}")

        print(f"[DEBUG] Available slots={available_slots}, requested={requested_slot}")
        if requested_slot not in available_slots:
            print(f"[WARNING] Requested slot {requested_slot} unavailable for medic {appointment_payload.medic_id}")
            raise HTTPException(409, "Unavailable time slot")

        encrypted_fields = encrypt_fields({
            "address":appointment_payload.address,
            "appointment_start":appointment_start.isoformat(),
            "appointment_end":appointment_end.isoformat(),
            "appointment_status":"pending",
            "medical_service_name":medical_service.name,
            "medical_service_price":str(medical_service.price),
        }, ENCRYPTED_APPOINTMENT_FIELDS)

        new_appointment=await self._appointment_repository.create(
            user_id=user_id,
            medic_id=appointment_payload.medic_id,
            medical_service_id=appointment_payload.medical_service_id,
            city_id=medic_entity.city_id,
            address=encrypted_fields["address"],
            appointment_start=encrypted_fields["appointment_start"],
            appointment_end=encrypted_fields["appointment_end"],
            appointment_status=encrypted_fields["appointment_status"],
            medical_service_name=encrypted_fields["medical_service_name"],
            medical_service_price=encrypted_fields["medical_service_price"],
        )

        return await self._map_appointment_to_schema(new_appointment.id)


    async def change_appointment_status(self, current_account: Union[Medic, User], appointment_id: int, new_appointment_status: str) -> AppointmentOutSchema:
        print(f"[INFO] Changing status for appointment_id={appointment_id} to {new_appointment_status} by account_id={current_account.id}")

        appointment_record = await self._appointment_repository.get_by_id(appointment_id)
        
        if not appointment_record:
            print(f"[ERROR] Appointment {appointment_id} not found for status change")
            raise HTTPException(404, "Appointment not found")

        is_medic=isinstance(current_account, Medic)
        
        if (is_medic and appointment_record.medic_id!=current_account.id) or (not is_medic and appointment_record.user_id!=current_account.id):
            print(f"[WARNING] Account {current_account.id} unauthorized to change appointment {appointment_id}")
            raise HTTPException(403, "Not permitted to change this appointment")

        encrypted_status = encrypt_data(new_appointment_status)
        
        await self._appointment_repository.update(appointment_id, {"appointment_status":encrypted_status})
        return await self._map_appointment_to_schema(appointment_id)

    async def accept_appointment(self, medic: Medic, appointment_id: int) -> AppointmentOutSchema:
        await self._ensure_medic_owns_appointment(medic.id, appointment_id)
        return await self.change_appointment_status(medic, appointment_id, "accepted")

    async def reject_appointment(self, medic: Medic, appointment_id: int) -> AppointmentOutSchema:
        await self._ensure_medic_owns_appointment(medic.id, appointment_id)
        return await self.change_appointment_status(medic, appointment_id, "rejected")

    async def complete_appointment(self, medic: Medic, appointment_id: int) -> AppointmentOutSchema:
        await self._ensure_medic_owns_appointment(medic.id, appointment_id)
        return await self.change_appointment_status(medic, appointment_id, "completed")

    async def cancel_user_appointment(self, user: User, appointment_id: int) -> AppointmentOutSchema:
        await self._ensure_user_owns_appointment(user.id, appointment_id)
        return await self.change_appointment_status(user, appointment_id, "canceled")

    async def cancel_medic_appointment(self, medic: Medic, appointment_id: int) -> AppointmentOutSchema:
        await self._ensure_medic_owns_appointment(medic.id, appointment_id)
        return await self.change_appointment_status(medic, appointment_id, "canceled")
