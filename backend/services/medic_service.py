from typing import List, Optional
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.user import get_user_by_id
from backend.database.sql_models import Medic
from backend.schemas.user_health_data_schemas import UserHealthDataOutSchema
from backend.schemas.user_schemas import PatientOut
from backend.services.location_service import matches_location
from ..crud.medic import (
get_all_medics_with_location,
get_encrypted_patients_assigned_to_medic,
get_medic_by_email,
get_medic_by_id,
create_medic,
)
from ..schemas.medic_schemas import MedicCreate, MedicOut
from ..core.auth import create_access_token
from ..utils.encryption_utils import decrypt_data, decrypt_fields, decrypt_medic_fields

async def signup_medic(db: AsyncSession, medic: MedicCreate):
    is_medic_found = await get_medic_by_email(db, email=medic.email)
    
    if is_medic_found:
        raise HTTPException(status_code=400, detail="A medic with the same email is already registered")
    
    created_medic = await create_medic(db=db, medic=medic)
    access_token = create_access_token(data={"sub": created_medic.id, "role": "medic"})
    
    return access_token

async def check_medic_email_availability(db: AsyncSession, email: str):
    is_medic_found = await get_medic_by_email(db, email=email)
   
    if is_medic_found:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    return {"available": True}

async def get_existing_medic_by_id(db: AsyncSession, medic_id: int) -> MedicOut:
    medic = await get_medic_by_id(db, medic_id)
    
    if not medic:
        raise HTTPException(status_code=404, detail="Medic not found")
    
    return decrypt_medic_fields(medic)

async def filter_medics_by_location(
    db: AsyncSession,
    city: Optional[str] = None,
    country: Optional[str] = None
) -> List[MedicOut]:
    
    rows = await get_all_medics_with_location(db)
    filtered: List[MedicOut] = []

    for medic, city_obj, country_obj in rows:
        plain_city    = decrypt_data(city_obj.name)
        plain_country = decrypt_data(country_obj.name)

        if city and not plain_city.lower().startswith(city.lower()):
            continue
        if country and not plain_country.lower().startswith(country.lower()):
            continue

        filtered.append(decrypt_medic_fields(medic, city_obj, country_obj))

    return filtered


async def get_all_patients_assigned_to_medic(db: AsyncSession, current_medic: Medic):
    encrypted_patients = await get_encrypted_patients_assigned_to_medic(db, current_medic.id)
    
    return [
        PatientOut(
            id=patient.id,
            **decrypt_fields(patient, ["first_name", "last_name"]),
            shares_data_with_medic=patient.share_data_with_medic,
        )
        for patient in encrypted_patients
    ]

#TODO: Maybe the user does not have yet a user health data
async def get_shared_patient_health_data(db: AsyncSession, current_medic: Medic, user_id: int):
    patient = await get_user_by_id(db, user_id)

    if patient.medic_id != current_medic.id:
        raise HTTPException(status_code=403, detail="You are not authorized to access this patient's data")
    
    if not patient.share_data_with_medic:
        raise HTTPException(status_code=403, detail="This patient has not shared their data with you")
    
    if not patient.health_data:
        raise HTTPException(status_code=404, detail="No health data found for this patient")

    decrypted_user_health_data_fields = decrypt_fields(
        patient.health_data,
        ["birth_date", "height", "weight", "cholesterol_level", "ap_hi", "ap_lo"]
    )

    return UserHealthDataOutSchema(**decrypted_user_health_data_fields)
