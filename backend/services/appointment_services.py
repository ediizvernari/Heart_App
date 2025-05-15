from datetime import datetime
from typing import List
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from backend.crud.appointments import (
    create_user_appointment,
    get_encrypted_appointment_by_id,
    get_encrypted_user_appointments,
    get_encrypted_medic_appointments,
    update_appointment,
    delete_appointment,
)

from backend.schemas.appointment_schemas import (
    AppointmentCreateSchema,
    AppointmentOutSchema,
)
from backend.services.medical_service import get_decrypted_medical_service_by_id
from backend.services.scheduling_services import get_free_time_slots_for_a_day
from backend.utils.encryption_utils import encrypt_data, encrypt_fields, decrypt_fields
from backend.database.sql_models import User, Medic

async def _ensure_medic_owns_appointment(db: AsyncSession, current_medic: Medic, appointment_id: int):
    appointment = await get_encrypted_appointment_by_id(db, appointment_id)
    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
    if appointment.medic_id != current_medic.id:
        raise HTTPException(status_code=403, detail="Not authorized to cancel this appointment")

async def _ensure_user_has_appointment(db: AsyncSession, current_user: User, appointment_id: int):
    appointment = await get_encrypted_appointment_by_id(db, appointment_id)
    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
    if appointment.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to cancel this appointment")

async def get_decrypted_appointment_by_id(db: AsyncSession, appointment_id: int) -> AppointmentOutSchema:
    encrypted_appointment = await get_encrypted_appointment_by_id(db, appointment_id)

    decrypted_fields = decrypt_fields(encrypted_appointment, ["address", "appointment_start", "appointment_end", "appointment_status"])

    return AppointmentOutSchema(
        id=appointment_id,
        user_id=encrypted_appointment.user_id,
        medic_id=encrypted_appointment.medic_id,
        medical_service_id=encrypted_appointment.medical_service_id,
        address=decrypted_fields["address"],
        appointment_start=decrypted_fields["appointment_start"],
        appointment_end=decrypted_fields["appointment_end"],
        appointment_status=decrypted_fields["appointment_status"],
        created_at=encrypted_appointment.created_at,
        updated_at=encrypted_appointment.updated_at,
    )

async def get_decrypted_user_appointments(db: AsyncSession, current_user: User) -> List[AppointmentOutSchema]:
    encrypted_user_appointments = await get_encrypted_user_appointments(db, current_user.id)

    decrypted_user_appointments: List[AppointmentOutSchema] = []
    for user_appointment in encrypted_user_appointments:
        decrypted_fields = decrypt_fields(user_appointment, ["address", "appointment_start", "appointment_end", "appointment_status"])
        decrypted_user_appointments.append(AppointmentOutSchema(
            id=user_appointment.id,
            user_id=user_appointment.user_id,
            medic_id=user_appointment.medic_id,
            medical_service_id=user_appointment.medical_service_id,
            address=decrypted_fields["address"],
            appointment_start=datetime.fromisoformat(decrypted_fields["appointment_start"]),
            appointment_end=datetime.fromisoformat(decrypted_fields["appointment_end"]),
            appointment_status=decrypted_fields["appointment_status"],
            created_at=user_appointment.created_at,
            updated_at=user_appointment.updated_at,
        ))
    
    return decrypted_user_appointments

async def get_decrypted_medic_appointments(db: AsyncSession, medic_id: int) -> List[AppointmentOutSchema]:
    encrypted_medic_appointments = await get_encrypted_medic_appointments(db, medic_id)

    decrypted_medic_appointments: List[AppointmentOutSchema] = []
    for user_appointment in encrypted_medic_appointments:
        decrypted_fields = decrypt_fields(user_appointment, ["address", "appointment_start", "appointment_end", "appointment_status"])
        decrypted_medic_appointments.append(AppointmentOutSchema(
            id=user_appointment.id,
            user_id=user_appointment.user_id,
            medic_id=user_appointment.medic_id,
            medical_service_id=user_appointment.medical_service_id,
            address=decrypted_fields["address"],
            appointment_start= datetime.fromisoformat(decrypted_fields["appointment_start"]),
            appointment_end=datetime.fromisoformat(decrypted_fields["appointment_end"]),
            appointment_status=decrypted_fields["appointment_status"],
            created_at=user_appointment.created_at,
            updated_at=user_appointment.updated_at,
        ))
    
    return decrypted_medic_appointments

async def create_appointment(db: AsyncSession, current_user: User, appointment_payload: AppointmentCreateSchema) -> AppointmentOutSchema:
    medical_service = await get_decrypted_medical_service_by_id(db, appointment_payload.medical_service_id)

    if not medical_service:
        raise HTTPException(404, detail="Medical Service not found")
    
    try:
        date_start = appointment_payload.appointment_start
        date_end = appointment_payload.appointment_end
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid datetime format")
    
    target_date = date_start.date()
    free_slot_models = await get_free_time_slots_for_a_day(
        db, appointment_payload.medic_id, target_date, medical_service.duration_minutes
    )
    free_slots = [(slot.start, slot.end) for slot in free_slot_models]  # this is critical

    requested_slot = (
        f"{date_start.hour:02d}:{date_start.minute:02d}",
        f"{date_end.hour:02d}:{date_end.minute:02d}"
    )

    print(f"[DEBUG] Comparing against raw slots: {free_slots}")
    print(f"[DEBUG] Requested slot: {requested_slot}")

    if requested_slot not in free_slots:
        raise HTTPException(status_code=409, detail="Unavailable time slot")
    
    encrypted_fields = encrypt_fields({
        "address":           appointment_payload.address,
        "appointment_start": appointment_payload.appointment_start.isoformat(),
        "appointment_end":   appointment_payload.appointment_end.isoformat(),
        "appointment_status": "pending"
    }, ["address", "appointment_start", "appointment_end", "appointment_status"])

    appointment = await create_user_appointment(
        db,
        user_id = current_user.id,
        medic_id=appointment_payload.medic_id,
        medical_service_id=appointment_payload.medical_service_id,
        address=encrypted_fields["address"],
        appointment_start=encrypted_fields["appointment_start"],
        appointment_end=encrypted_fields["appointment_end"],
        appointment_status=encrypted_fields["appointment_status"],
    )

    return await get_decrypted_appointment_by_id(db, appointment.id)

async def change_appointment_status(db: AsyncSession, current_account: User | Medic, appointment_id: int, new_appointment_status: str):
    appointment = await get_encrypted_appointment_by_id(db, appointment_id)
    if not appointment:
        raise HTTPException(404, detail="Appointment not found")
    
    if isinstance(current_account, Medic):
        if appointment.medic_id != current_account.id:
            raise HTTPException(403, "Not permitted to change this appointment")
    else:
        if appointment.user_id != current_account.id:
            raise HTTPException(403, "Not permitted to change this appointment")

    encrypted_new_status = encrypt_data(new_appointment_status)
    await update_appointment(db, appointment_id, {"appointment_status": encrypted_new_status})

    return await get_decrypted_appointment_by_id(db, appointment_id)

async def accept_appointment(db: AsyncSession, current_medic: Medic, appointment_id: int):
    await _ensure_medic_owns_appointment(db, current_medic, appointment_id)
    
    return await change_appointment_status(db, current_medic, appointment_id, "accepted")

async def reject_appointment(db: AsyncSession, current_medic: Medic, appointment_id: int):
    await _ensure_medic_owns_appointment(db, current_medic, appointment_id)

    return await change_appointment_status(db, current_medic, appointment_id, "rejected")

async def complete_appointment(db: AsyncSession, current_medic: Medic, appointment_id: int):
    await _ensure_medic_owns_appointment(db, current_medic, appointment_id)

    return await change_appointment_status(db, current_medic, appointment_id, "completed")

async def cancel_user_appointment(db: AsyncSession, current_user: User, appointment_id: int) -> None:
    await _ensure_user_has_appointment(db, current_user, appointment_id)

    return await change_appointment_status(db, current_user, appointment_id, "canceled")

async def cancel_medic_appointment(db: AsyncSession, current_medic: Medic, appointment_id: int) -> None:
    await _ensure_medic_owns_appointment(db, current_medic, appointment_id)

    return await change_appointment_status(db, current_medic, appointment_id, "canceled")
    