from typing import Optional
from fastapi import HTTPException   #TODO: Maybe move this check into the router file
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from argon2 import PasswordHasher
from ..database.sql_models import Medic
from ..schemas.medic_schemas import MedicCreate
from ..utils.encryption_utils import encrypt_data

ph = PasswordHasher()

async def create_medic(db: AsyncSession, medic: MedicCreate) :
    hashed_password = ph.hash(medic.password)
    encrypted_first_name = encrypt_data(medic.first_name)
    encrypted_last_name = encrypt_data(medic.last_name)
    encrypted_street_address = encrypt_data(medic.street_address)
    encrypted_city = encrypt_data(medic.city)
    encrypted_region = encrypt_data(medic.region)
    encrypted_country = encrypt_data(medic.country)

    db_medic = Medic(
        first_name=encrypted_first_name,
        last_name=encrypted_last_name,
        email=medic.email,
        password=hashed_password,
        street_address=encrypted_street_address,
        city=encrypted_city,
        region=encrypted_region,
        country=encrypted_country
    )
    db.add(db_medic)
    await db.commit()
    await db.refresh(db_medic)
    return db_medic

async def get_medic_by_id(db: AsyncSession, medic_id: int):
    result = await db.execute(select(Medic).where(Medic.id == medic_id))
    return result.scalar_one_or_none()

async def get_medic_by_email(db: AsyncSession, email: str):
    result = await db.execute(select(Medic).where(Medic.email == email))
    return result.scalar_one_or_none()

async def get_filtered_medics(db: AsyncSession,city: Optional[str] = None, region: Optional[str] = None, country: Optional[str] = None):
    query = select(Medic)
    if city:
        query = query.where(Medic.city == city)
    if region:
        query = query.where(Medic.region == region)
    if country:
        query = query.where(Medic.country == country)
    result = await db.execute(query)
    return result.scalars().all()