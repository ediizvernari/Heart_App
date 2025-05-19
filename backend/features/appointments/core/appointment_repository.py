from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.utils import (
    create_entity,
    get_entity_by_id,
    list_entities,
    update_entity_by_id,
    delete_entity_by_id,
)
from backend.database.sql_models import Appointment

class AppointmentRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_user_appointment(self, **appointment_arguments) -> Appointment:
        return await create_entity(self.db, Appointment, **appointment_arguments)

    async def get_appointment_by_id(self, appointment_id: int) -> Appointment | None:
        return await get_entity_by_id(self.db, Appointment, appointment_id)

    async def update_appointment(self, appointment_id: int, values: dict) -> None:
        await update_entity_by_id(self.db, Appointment, appointment_id, values)

    async def delete_appointment(self, appointment_id: int) -> None:
        await delete_entity_by_id(self.db, Appointment, appointment_id)

    async def get_medic_appointments(self, medic_id: int) -> list[Appointment]:
        return await list_entities(self.db, Appointment, filters=[Appointment.medic_id == medic_id])

    async def get_user_appointments(self, user_id: int) -> list[Appointment]:
        return await list_entities(self.db, Appointment, filters=[Appointment.user_id == user_id])
        
    async def get_user_appointments_by_status(self, user_id: int, appointment_status) -> list[Appointment]:
        return await list_entities(self.db, Appointment, filters=[Appointment.user_id == user_id, Appointment.appointment_status == appointment_status])
