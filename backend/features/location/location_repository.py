from typing import List, Optional, Tuple
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from backend.core.repository.generic_repository import GenericRepository
from backend.database.sql_models import Country, City


class CountryRepository(GenericRepository[Country]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, Country)

    async def get_by_lookup_hash(self, lookup_hash: str) -> Optional[Country]:
        return await self.get_by_field(Country.lookup_hash == lookup_hash)


class CityRepository(GenericRepository[City]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, City)

    async def get_by_lookup_hash_and_country_id(self, lookup_hash: str, country_id: int) -> Optional[City]:
        return await self.get_by_field(City.lookup_hash == lookup_hash, City.country_id == country_id)


class LocationRepository:
    def __init__(self, db: AsyncSession):
        self.country_repo = CountryRepository(db)
        self.city_repo = CityRepository(db)
        self._db = db

    # ─── Countries ────────────────────────────────────────────────────────────

    async def create_country(self, encrypted_name: str, lookup_hash: str) -> Country:
        return await self.country_repo.create(name=encrypted_name, lookup_hash=lookup_hash)

    async def get_country_by_id(self, country_id: int) -> Optional[Country]:
        return await self.country_repo.get_by_id(country_id)

    async def get_country_by_lookup_hash(self, lookup_hash: str) -> Optional[Country]:
        return await self.country_repo.get_by_lookup_hash(lookup_hash)

    async def get_all_countries(self) -> List[Country]:
        return await self.country_repo.list()

    # ─── Cities ────────────────────────────────────────────────────────────────

    async def create_city(self, encrypted_name: str, lookup_hash: str, country_id: int) -> City:
        return await self.city_repo.create(name=encrypted_name, lookup_hash=lookup_hash, country_id=country_id)

    async def get_city_by_id(self, city_id: int) -> Optional[City]:
        return await self.city_repo.get_by_id(city_id)

    async def get_city_by_lookup_hash_and_country_id(self, lookup_hash: str, country_id: int) -> Optional[City]:
        return await self.city_repo.get_by_lookup_hash_and_country_id(lookup_hash, country_id)

    async def get_all_cities_with_countries(self) -> List[Tuple[City, Country]]:
        statement   = select(City, Country).join(Country)
        result = await self._db.execute(statement)
        return result.all()

    async def is_city_from_country(self, city_name: str, country_id: int) -> bool:
        statement   = select(City).where(City.name == city_name, City.country_id == country_id)
        result = await self._db.execute(statement)
        return result.scalar_one_or_none() is not None
