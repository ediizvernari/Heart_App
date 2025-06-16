from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from backend.crud.utils import create_entity, get_entity_by_field
from backend.database.sql_models import MedicRegistry

class MedicRegistryRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def count_medics_in_registry(self) -> int:
        return await self.db.scalar(select(func.count()).select_from(MedicRegistry))
    
    async def create_medic_for_registry(self, first_name: str, last_name: str, license_number: str, lookup_hash: str):
        return await create_entity(
            self.db, MedicRegistry,
            first_name=first_name, 
            last_name=last_name, 
            license_number=license_number,
            lookup_hash=lookup_hash
            )
    
    async def get_registry_medic_by_lookup_hash(self, lookup_hash: str) -> MedicRegistry | None:
        return await get_entity_by_field(self.db, MedicRegistry, MedicRegistry.lookup_hash == lookup_hash)