from typing import Optional
from sqlalchemy import func
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.repository.generic_repository import GenericRepository
from backend.core.database.sql_models import MedicalServiceType

class MedicalServiceTypeRepository(GenericRepository[MedicalServiceType]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, MedicalServiceType)

    async def count(self) -> int:
        stmt = select(func.count()).select_from(MedicalServiceType)
        result = await self.db.execute(stmt)
        return result.scalar_one()

    async def get_by_name(self, name: str) -> Optional[MedicalServiceType]:
        return await self.get_by_field(MedicalServiceType.name == name)