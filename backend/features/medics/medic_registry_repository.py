from typing import Optional
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from backend.core.repository.generic_repository import GenericRepository
from backend.core.database.sql_models import MedicRegistry

class MedicRegistryRepository(GenericRepository[MedicRegistry]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, MedicRegistry)

    async def count_medics_in_registry(self) -> int:
        return await self.db.scalar(select(func.count()).select_from(MedicRegistry))

    async def create_medic_for_registry(self, first_name: str, last_name: str, license_number: str, lookup_hash: str) -> MedicRegistry:
        return await self.create(
            first_name = first_name,
            last_name = last_name,
            license_number = license_number,
            lookup_hash = lookup_hash
        )

    async def get_registry_medic_by_lookup_hash(self, lookup_hash: str) -> Optional[MedicRegistry]:
        return await self.get_by_field(MedicRegistry.lookup_hash == lookup_hash)
