from typing import Any, List
from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.repository.generic_repository import GenericRepository
from backend.database.sql_models import Appointment

class AppointmentRepository(GenericRepository[Appointment]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, Appointment)

    async def get_medic_appointments(self, medic_id: int) -> List[Appointment]:
        return await self.list(filters=[Appointment.medic_id == medic_id])

    async def get_user_appointments(self, user_id: int) -> List[Appointment]:
        return await self.list(filters=[Appointment.user_id == user_id])
        
    async def get_user_appointments_by_status(self, user_id: int, appointment_status: Any) -> List[Appointment]:
        return await self.list(filters=[Appointment.user_id == user_id, Appointment.appointment_status == appointment_status])
