from typing import List, Optional, Tuple
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession

from backend.crud.utils import create_entity, get_entity_by_field, list_entities
from backend.database.sql_models import City, Country, Medic, User

class MedicRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create_medic(self, **medic_arguments) -> Medic:
        return await create_entity(self.db, Medic, **medic_arguments)
    
    async def get_medic_by_id(self, medic_id: int) -> Optional[Medic]:
        return await get_entity_by_field(self.db, Medic, Medic.id==medic_id)
    
    async def get_medic_by_email(self, medic_email:str) -> Optional[Medic]:
        return await get_entity_by_field(self.db, Medic, Medic.email==medic_email)
    
    async def get_all_medics_with_location(self) -> List[Tuple[Medic, City, Country]]:
        get_all_medics_with_location_statement = select(Medic, City, Country).join(City, Medic.city_id == City.id).join(Country, City.country_id == Country.id)
        result = await self.db.execute(get_all_medics_with_location_statement)
        return result.all()
    
    async def get_assigned_users(self, medic_id: int) -> List[User]:
        return await list_entities(self.db, User, filters=[User.medic_id == medic_id])