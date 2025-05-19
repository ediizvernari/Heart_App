from typing import Any, List
from sqlalchemy.ext.asyncio import AsyncSession

from backend.crud.utils import (
    create_entity,
    get_entity_by_id,
    list_entities,
    update_entity_by_id,
    delete_entity_by_id,
)
from backend.database.sql_models import AppointmentSuggestion

class AppointmentSuggestionRepository:
    def __init__(self, db:AsyncSession):
        self.db = db

    async def create_appointment_suggestion(self, **appointment_suggestion_args) -> AppointmentSuggestion:
        return await create_entity(self.db, AppointmentSuggestion, **appointment_suggestion_args)

    async def get_appointment_suggestion_by_id(self, appointment_suggestion_id: int) -> AppointmentSuggestion | None:
        return await get_entity_by_id(self.db, AppointmentSuggestion, appointment_suggestion_id)

    async def get_user_appointment_suggestions(self, user_id: int) -> List[AppointmentSuggestion]:
        return await list_entities(self.db, AppointmentSuggestion, filters=[AppointmentSuggestion.user_id == user_id])

    async def get_medic_appointment_suggestions(self, medic_id: int) -> List[AppointmentSuggestion]:
        return await list_entities(self.db, AppointmentSuggestion, filters=[AppointmentSuggestion.medic_id == medic_id])

    async def update_appointment_suggestion(self, appointment_suggestion_id: int, values: dict[str, Any]) -> None:
        await update_entity_by_id(self.db, AppointmentSuggestion, appointment_suggestion_id, values)

    async def delete_appointment_suggestion(self, appointment_suggestion_id) -> None:
        await delete_entity_by_id(self.db, AppointmentSuggestion, appointment_suggestion_id)
