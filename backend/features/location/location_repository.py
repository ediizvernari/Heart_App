from typing import Optional, List, Tuple
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from backend.crud.utils import (
    create_entity,
    get_entity_by_field,
    get_entity_field_by_id,
    list_entities,
    get_entity_by_id
)
from backend.database.sql_models import City, Country
from backend.utils.encryption_utils import encrypt_data

class LocationRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    #Country methods
    async def create_country(self, name:str) -> Country:
        return await create_entity(self.db, Country, name=name)
    
    async def get_country_by_id(self, country_id: int) -> Optional[Country]:
        return await get_entity_by_id(self.db, Country, country_id)
    
    async def get_country_id_by_name(self, country_name: str) -> int:
        encrypted_country_name = encrypt_data(country_name)
        country_id =  await get_entity_field_by_id(self.db, Country, Country.id, encrypted_country_name, identification_attr=Country.name)
        if country_id is None:
            raise HTTPException(404, "Country not found")
        return country_id
    
    async def get_country_by_name(self, country_name:str) -> Optional[Country]:
        encrypted_name = encrypt_data(country_name)
        return await get_entity_by_field(self.db, Country, Country.name == encrypted_name)
    
    async def get_all_countries(self) -> List[Country]:
        return await list_entities(self.db, Country)
    
    #City methods
    async def create_city(self, name: str, country_id: int) -> City:
        return await create_entity(self.db, City, name=name, country_id=country_id)
    
    async def get_city_by_id(self, city_id: int) -> Optional[City]:
        return await get_entity_by_field(self.db, City, City.id==city_id)
    
    async def get_all_cities_with_countries(self) -> List[Tuple[City, Country]]:
        statement = select(City, Country).join(Country)
        result = await self.db.execute(statement)
        return result.all()
    
    async def is_city_from_country(self, city_name: str, country_id: int) -> bool:
        statement = select(City).where(City.name == city_name, City.country_id == country_id)
        result = await self.db.execute(statement)
        return result.scalar_one_or_none() is not None
    
    async def get_city_by_name_and_country(self, city_name: str, country_id: int) -> Optional[City]:
        return await get_entity_by_field(self.db, City, City.name == city_name, City.country_id == country_id)
