from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.repository.generic_repository import GenericRepository
from backend.core.database.sql_models import MedicalService

class MedicalServiceRepository(GenericRepository[MedicalService]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, MedicalService)

    async def list_for_medic(self, medic_id: int) -> List[MedicalService]:
        return await self.list(filters=[MedicalService.medic_id == medic_id])

    async def get_by_id(self, service_id: int) -> Optional[MedicalService]:
        return await super().get_by_id(service_id)
