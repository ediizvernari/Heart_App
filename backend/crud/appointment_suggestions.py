from typing import Any
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.sql_models import AppointmentSuggestion
from backend.crud.utils import (
    create_entity,
    get_entity_by_id,
    list_entities,
    update_entity_by_id,
    delete_entity_by_id,
)

#TODO: Use this as an example for all the other crud files
async def create_appointment_suggestion(db: AsyncSession, **appointment_suggestion_args) -> AppointmentSuggestion:
    return await create_entity(db, AppointmentSuggestion, **appointment_suggestion_args)

async def get_encrypted_appointment_suggestion_by_id(db: AsyncSession, appointment_suggestion_id: int) -> AppointmentSuggestion | None:
    return await get_entity_by_id(db, AppointmentSuggestion, appointment_suggestion_id)

async def get_encrypted_user_appointment_suggestions(db: AsyncSession, user_id: int) -> list[AppointmentSuggestion]:
    return await list_entities(db, AppointmentSuggestion, filters=[AppointmentSuggestion.user_id == user_id])

async def get_encrypted_medic_appointment_suggestions(db: AsyncSession, medic_id: int) -> list[AppointmentSuggestion]:
    return await list_entities(db, AppointmentSuggestion, filters=[AppointmentSuggestion.medic_id == medic_id])

async def update_appointment_suggestion(db: AsyncSession, appointment_suggestion_id: int, values: dict[str, Any]) -> None:
    await update_entity_by_id(db, AppointmentSuggestion, appointment_suggestion_id, values)

async def delete_appointment_suggestion(db: AsyncSession, appointment_suggestion_id) -> None:
    await delete_entity_by_id(db, AppointmentSuggestion, appointment_suggestion_id)
