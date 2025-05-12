from typing import List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.connection import get_db
from backend.database.sql_models import Medic
from backend.schemas.medic_schemas import MedicOut
from backend.schemas.user_health_data_schemas import UserHealthDataOutSchema
from backend.schemas.user_medical_records_schemas import UserMedicalRecordOutSchema
from backend.schemas.user_schemas import PatientOut
from backend.services.account_service import get_current_account
from backend.services.medic import filter_medics_by_location, get_all_patients_assigned_to_medic, get_shared_patient_health_data
from backend.services.user_medical_record_service import get_all_user_medical_records_for_specific_assigned_user, get_latest_user_medical_record_for_specific_assigned_user

router = APIRouter()

@router.get("/filtered_medics", response_model=List[MedicOut])
async def get_all_medics_filtered_by_location(
    city: str = Query(None),
    country: str = Query(None),
    db: AsyncSession = Depends(get_db)
):
    return await filter_medics_by_location(db, city, country)

@router.get("/patients", response_model=List[PatientOut])
async def get_decrypted_patients_assigned_to_medic(
    db: AsyncSession = Depends(get_db),
    current_medic: Medic = Depends(get_current_account)
):
    
    return await get_all_patients_assigned_to_medic(db, current_medic)

@router.get("/patients/{user_id}/data", response_model=UserHealthDataOutSchema)
async def get_patient_health_data(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_medic: Medic = Depends(get_current_account)
):
    return await get_shared_patient_health_data(db=db, current_medic=current_medic, user_id=user_id)

@router.get("/patients/{user_id}/medical_records", response_model=List[UserMedicalRecordOutSchema])
async def get_all_user_medical_records_for_one_specific_assigned_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_medic: Medic = Depends(get_current_account)
):
    return await get_all_user_medical_records_for_specific_assigned_user(db=db, current_medic=current_medic, user_id=user_id)

@router.get("/patients/{user_id}/medical_records/latest", response_model=UserMedicalRecordOutSchema)
async def get_latest_user_medical_record_for_one_specific_assigned_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_medic: Medic = Depends(get_current_account)
):
    return await get_latest_user_medical_record_for_specific_assigned_user(db=db, current_medic=current_medic, user_id=user_id)