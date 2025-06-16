from typing import Any, List
from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.repository.generic_repository import GenericRepository
from backend.database.sql_models import AppointmentSuggestion

class AppointmentSuggestionRepository(GenericRepository[AppointmentSuggestion]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, AppointmentSuggestion)

    async def get_user_appointment_suggestions(self, user_id: int) -> List[AppointmentSuggestion]:
        return await self.list(filters=[AppointmentSuggestion.user_id==user_id])

    async def get_medic_appointment_suggestions(self, medic_id: int) -> List[AppointmentSuggestion]:
        return await self.list(filters=[AppointmentSuggestion.medic_id==medic_id])