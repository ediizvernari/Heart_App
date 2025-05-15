from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.sql_models import Appointment
from backend.crud.utils import create_entity, list_entities, update_entity_by_id, delete_entity_by_id, get_entity_by_id
from backend.utils.encryption_utils import encrypt_data

#TODO: Take this as an example for all the other entities
async def create_user_appointment(db: AsyncSession, **appointment_arguments) -> Appointment:
    return await create_entity(db, Appointment, **appointment_arguments)

async def get_encrypted_appointment_by_id(db: AsyncSession, appointment_id: int) -> Appointment | None:
    return await get_entity_by_id(db, Appointment, appointment_id)

async def update_appointment(db: AsyncSession, appointment_id: int, values: dict) -> None:
    await update_entity_by_id(db, Appointment, appointment_id, values)

async def delete_appointment(db: AsyncSession, appointment_id: int) -> None:
    await delete_entity_by_id(db, Appointment, appointment_id)

async def get_encrypted_medic_appointments(db: AsyncSession, medic_id: int) -> list[Appointment]:
    return await list_entities(db, Appointment, filters=[Appointment.medic_id == medic_id])

async def get_encrypted_user_appointments(db: AsyncSession, user_id: int) -> list[Appointment]:
    return await list_entities(db, Appointment, filters=[Appointment.user_id == user_id])
    
async def get_encrypted_user_appointments_by_status(db: AsyncSession, user_id: int, appointment_status) -> list[Appointment]:
    return await list_entities(db, Appointment, filters=[Appointment.user_id == user_id, Appointment.appointment_status == appointment_status])

