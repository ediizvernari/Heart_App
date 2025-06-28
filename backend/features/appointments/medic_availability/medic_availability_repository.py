from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.repository.generic_repository import GenericRepository
from backend.core.database.sql_models import MedicAvailability

class MedicAvailabilityRepository(GenericRepository[MedicAvailability]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, MedicAvailability)

    async def get_medic_availabilities(self, medic_id: int) -> list[MedicAvailability]:
        return await self.list(filters=[MedicAvailability.medic_id==medic_id])