from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.utils import create_entity, delete_entity_by_id, list_entities, update_entity_by_id, get_entity_by_id
from backend.database.sql_models import MedicAvailability

class MedicAvailabilityRepository:
    def  __init__(self, db: AsyncSession):
        self.db = db

    async def create_medic_availability(self, **medic_availability_arguments) -> MedicAvailability:
        return await create_entity(self.db, MedicAvailability, **medic_availability_arguments)

    async def get_encrypted_medic_availabilities(self, medic_id: int) -> list[MedicAvailability]:
        return await list_entities(self.db, MedicAvailability, filters=[MedicAvailability.medic_id == medic_id])

    async def get_medic_availability_by_id(self, medic_availability_id: int) -> MedicAvailability | None:
        return await get_entity_by_id(self.db, MedicAvailability, medic_availability_id)

    async def update_medic_availability_by_id(self, medic_availability_id: int, updated_medic_availability_values: dict) -> None:
        await update_entity_by_id(self.db, MedicAvailability, medic_availability_id, updated_medic_availability_values)

    async def delete_medic_availability_by_id(self, medic_availability_id: int) -> None:
        await delete_entity_by_id(self.db, MedicAvailability, medic_availability_id)
    