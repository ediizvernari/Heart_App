from typing import List
from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.location import get_all_cities_with_countries, get_all_countries
from ..schemas.location_schemas import CityWithCountrySchema, CountrySchema
from ..utils.encryption_utils import encrypt_data, decrypt_data
from sqlalchemy.future import select


def matches_location(city_obj, country_obj, filter_city: str = None, filter_country: str = None) -> bool:
    decrypted_city = decrypt_data(city_obj.name).lower()
    decrypted_country = decrypt_data(country_obj.name).lower()

    return (
        (not filter_city or decrypted_city == filter_city.lower()) and
        (not filter_country or decrypted_country == filter_country.lower())
    )

async def autocomplete_cities(db: AsyncSession, query: str) -> List[CityWithCountrySchema]:
    query = query.lower()
    encrypted_cities_with_countries = await get_all_cities_with_countries(db)

    return [
        CityWithCountrySchema(city=decrypt_data(city.name), country=decrypt_data(country.name))

        for city, country in encrypted_cities_with_countries
        if query in decrypt_data(city.name).lower()
    ]

async def get_decrypted_countries(db: AsyncSession) -> List[CountrySchema]:
    encrypted_countries  = await get_all_countries(db)

    return [CountrySchema(name=decrypt_data(country_name)) for country_name in encrypted_countries]