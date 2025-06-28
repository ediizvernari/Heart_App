from typing import List, Optional, Tuple
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.repository.generic_repository import GenericRepository
from backend.core.database.sql_models import Medic, City, Country, User

class MedicRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
        self._medic_repo = GenericRepository(db, Medic)
        self._user_repo = GenericRepository(db, User)

    async def create_medic(self, **medic_arguments) -> Medic:
        return await self._medic_repo.create(**medic_arguments)

    async def get_medic_by_id(self, medic_id: int) -> Optional[Medic]:
        return await self._medic_repo.get_by_id(medic_id)

    async def get_medic_by_email(self, medic_email: str) -> Optional[Medic]:
        return await self._medic_repo.get_by_field(Medic.email == medic_email)

    async def get_all_medics_with_location(self) -> List[Tuple[Medic, City, Country]]:
        get_all_medics_with_location_statement = select(Medic, City, Country).join(City, Medic.city_id == City.id).join(Country, City.country_id == Country.id)
        result = await self.db.execute(get_all_medics_with_location_statement)
        return result.all()

    async def get_assigned_users(self, medic_id: int) -> List[User]:
        return await self._user_repo.list(filters=[User.medic_id == medic_id])