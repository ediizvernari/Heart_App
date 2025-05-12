from fastapi import HTTPException   #TODO: Maybe move this check into the router file
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.utils import get_entity_by_id
from backend.database.sql_models import City, Country
from ..utils.encryption_utils import encrypt_data, decrypt_data
from ..schemas.location_schemas import CityWithCountrySchema, CountrySchema

async def get_country_id_by_name(db: AsyncSession, country_name: str) -> int:
    encrypted_name = encrypt_data(country_name)

    result = await db.execute(
        select(Country.id).where(Country.name == encrypted_name)
    )
    country_id = result.scalar_one_or_none()
    if country_id is None:
        raise HTTPException(status_code=404, detail="Country not found")
    return country_id

async def create_country(db: AsyncSession, country: CountrySchema) -> Country:
    encrypted_country_name = encrypt_data(country.name)

    db_country = Country(name=encrypted_country_name)
    db.add(db_country)

    await db.commit()
    await db.refresh(db_country)
    
    return db_country

async def is_city_from_country(db: AsyncSession, city_name: str, country_name: str) -> bool:
    encrypted_city_name = encrypt_data(city_name)
    encrypted_country_name = encrypt_data(country_name)

    result = await db.execute(
        select(Country).where(Country.name == encrypted_country_name)
    )
    country = result.scalar_one_or_none()

    if not country:
        return False

    result = await db.execute(
        select(City).where(City.name == encrypted_city_name, City.country_id == country.id)
    )
    return result.scalar_one_or_none() is not None
        
async def create_city(db: AsyncSession, city_with_country: CityWithCountrySchema):
    encrypted_country_name = encrypt_data(city_with_country.country)
    encrypted_city_name = encrypt_data(city_with_country.city)

    result = await db.execute(select(Country).where(Country.name == encrypted_country_name))
    country = result.scalar_one_or_none()

    if not country:
        country = await create_country(db, CountrySchema(name=city_with_country.country))
    country_id = country.id

    db_city = City(name=encrypted_city_name, country_id=country_id)
    db.add(db_city)
    await db.commit()
    await db.refresh(db_city)

    return db_city

async def get_all_cities_with_countries(db: AsyncSession):
    result = await db.execute(select(City, Country).join(Country))
    return result.all()

async def get_all_countries(db: AsyncSession):
    result = await db.execute(select(Country))
    return result.scalars().all()

async def get_encrypted_city_by_id(db: AsyncSession, city_id: int) -> City | None:
    return await get_entity_by_id(db, City, city_id)

async def get_encrypted_country_by_id(db: AsyncSession, country_id: int) -> Country | None:
    return await get_entity_by_id(db, Country, country_id)