from typing import List, Optional

from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from backend.crud.user import get_user_by_id
from backend.database.sql_models import Medic
from backend.schemas.medic_schemas import MedicOut, MedicCreate
from backend.schemas.user_health_data_schemas import UserHealthDataOutSchema
from backend.schemas.user_schemas import PatientOut

from backend.crud.medic import (
    get_all_medics_with_location,
    get_encrypted_patients_assigned_to_medic,
    get_medic_by_email,
    get_medic_by_id,
    create_medic,
)

from backend.core.auth import create_access_token
from backend.utils.encryption_utils import decrypt_data, decrypt_fields
from backend.services.location_service import (
    get_decrypted_city_name_by_id,
    get_decrypted_country_name_by_city_id,
)


async def signup_medic(db: AsyncSession, medic: MedicCreate) -> str:
    existing = await get_medic_by_email(db, email=medic.email)
    if existing:
        raise HTTPException(
            status_code=400,
            detail="A medic with that email is already registered"
        )
    created = await create_medic(db=db, medic=medic)
    return create_access_token(data={"sub": created.id, "role": "medic"})


async def check_medic_email_availability(db: AsyncSession, email: str) -> dict:
    existing = await get_medic_by_email(db, email=email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    return {"available": True}


async def get_existing_medic_by_id(db: AsyncSession, medic_id: int) -> MedicOut:
    medic = await get_medic_by_id(db, medic_id)
    if not medic:
        raise HTTPException(status_code=404, detail="Medic not found")
    return await get_medic_dto_from_medic_object(db, medic)


async def filter_medics_by_location(db: AsyncSession, city: Optional[str] = None, country: Optional[str] = None) -> List[MedicOut]:
    rows = await get_all_medics_with_location(db)
    filtered_medics: List[MedicOut] = []

    for medic, city_obj, country_obj in rows:
        plain_city    = decrypt_data(city_obj.name)
        plain_country = decrypt_data(country_obj.name)

        if city and not plain_city.lower().startswith(city.lower()):
            continue
        if country and not plain_country.lower().startswith(country.lower()):
            continue

        filtered_medics.append(await get_medic_dto_from_medic_object(db, medic))

    return filtered_medics


async def get_all_patients_assigned_to_medic(db: AsyncSession, current_medic: Medic) -> List[PatientOut]:
    encrypted = await get_encrypted_patients_assigned_to_medic(db, current_medic.id)
    return [
        PatientOut(
            id=p.id,
            first_name=fields["first_name"],
            last_name=fields["last_name"],
            shares_data_with_medic=p.share_data_with_medic,
        )
        for p in encrypted
        for fields in [decrypt_fields(p, ["first_name", "last_name"])]
    ]


async def get_shared_patient_health_data(db: AsyncSession, current_medic: Medic, user_id: int) -> UserHealthDataOutSchema:
    patient = await get_user_by_id(db, user_id)

    if patient.medic_id != current_medic.id:
        raise HTTPException(status_code=403, detail="Not authorized for this patient")
    if not patient.share_data_with_medic:
        raise HTTPException(status_code=403, detail="Patient has not shared data")
    if not patient.health_data:
        raise HTTPException(status_code=404, detail="No health data found")

    decrypted = decrypt_fields(
        patient.health_data,
        ["birth_date", "height", "weight", "cholesterol_level", "ap_hi", "ap_lo"]
    )
    return UserHealthDataOutSchema(**decrypted)


async def get_medic_dto_from_medic_object(db: AsyncSession, medic: Medic) -> MedicOut:
    base = decrypt_fields(medic, ["first_name", "last_name", "street_address"])

    city_name    = await get_decrypted_city_name_by_id(db, medic.city_id)
    country_name = await get_decrypted_country_name_by_city_id(db, medic.city_id)

    return MedicOut(
        id=medic.id,
        first_name=base["first_name"],
        last_name=base["last_name"],
        email=medic.email,
        street_address=base["street_address"],
        city=city_name,
        country=country_name,
    )
