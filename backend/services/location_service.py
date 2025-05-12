from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession

from backend.crud.location import (
    get_all_cities_with_countries,
    get_all_countries,
    get_encrypted_city_by_id,
    get_encrypted_country_by_id,
)
from backend.schemas.location_schemas import CityWithCountrySchema, CountrySchema
from backend.utils.encryption_utils import decrypt_data


def matches_location(city_obj, country_obj, filter_city: Optional[str] = None, filter_country: Optional[str] = None) -> bool:
    decrypted_city    = decrypt_data(city_obj.name).lower()
    decrypted_country = decrypt_data(country_obj.name).lower()

    if filter_city and not decrypted_city.startswith(filter_city.lower()):
        return False
    if filter_country and not decrypted_country.startswith(filter_country.lower()):
        return False
    return True


async def autocomplete_cities(db: AsyncSession, query: str) -> List[CityWithCountrySchema]:
    query = query.lower()
    rows = await get_all_cities_with_countries(db)

    cities_with_country: List[CityWithCountrySchema] = []
    for city_object, country_object in rows:
        name = decrypt_data(city_object.name)
        if query in name.lower():
            cities_with_country.append(
                CityWithCountrySchema(
                    city=name,
                    country=decrypt_data(country_object.name)
                )
            )
    return cities_with_country


async def get_decrypted_countries(db: AsyncSession) -> List[CountrySchema]:
    encrypted = await get_all_countries(db)
    return [
        CountrySchema(name=decrypt_data(country.name))
        for country in encrypted
    ]


async def get_decrypted_city_name_by_id(db: AsyncSession, city_id: int) -> str:
    city_obj = await get_encrypted_city_by_id(db, city_id)
    return decrypt_data(city_obj.name)


async def get_decrypted_country_name_by_id(db: AsyncSession, country_id: int) -> str:
    country_obj = await get_encrypted_country_by_id(db, country_id)
    return decrypt_data(country_obj.name)


async def get_decrypted_country_name_by_city_id(db: AsyncSession, city_id: int) -> str:
    city_object = await get_encrypted_city_by_id(db, city_id)
    country_obj = await get_encrypted_country_by_id(db, city_object.country_id)
    return decrypt_data(country_obj.name)
