from typing import List
from fastapi import APIRouter, Depends, HTTPException, status, Query

from backend.core.database.sql_models import Medic
from backend.features.auth.deps                       import get_current_account
from backend.features.medics.deps                      import get_medic_service
from backend.features.medics.medic_schemas             import (
    MedicOutSchema,
    AssignedUserOutSchema,
)
from backend.features.medics.medic_service             import MedicService
from backend.features.user_health_data.user_health_data_schemas import UserHealthDataOutSchema
from backend.features.user_medical_record.deps        import get_user_medical_record_service
from backend.features.user_medical_record.user_medical_records_schemas import UserMedicalRecordOutSchema
from backend.features.user_health_data.user_health_data_service         import UserHealthDataService
from backend.features.user_medical_record.user_medical_record_service import UserMedicalRecordService

router = APIRouter()

@router.get("/filtered_medics", response_model=List[MedicOutSchema], dependencies=[Depends(get_current_account)])
async def get_all_medics_filtered_by_location(city: str = Query(None), country: str = Query(None), medic_service: MedicService = Depends(get_medic_service)):
    return await medic_service.filter_medics_by_location(city, country)

@router.get("/patients", response_model=List[AssignedUserOutSchema])
async def get_assigned_users_to_current_medic(current_medic: Medic = Depends(get_current_account), medic_service: MedicService = Depends(get_medic_service)):
    return await medic_service.get_medics_assigned_users(current_medic.id)

@router.get("/patients/{user_id}/medical_records/latest", response_model=UserMedicalRecordOutSchema)
async def get_latest_user_medical_record_for_one_specific_assigned_user(user_id: int, current_medic: Medic = Depends(get_current_account), medic_service: MedicService = Depends(get_medic_service), user_medical_record_service: UserMedicalRecordService = Depends(get_user_medical_record_service)):
    assigned_users = await medic_service.get_medics_assigned_users(current_medic.id)
    if not any(user.id == user_id for user in assigned_users):
        raise HTTPException(403, "Not authorized")
    return await user_medical_record_service.get_latest_user_medical_record_by_user_id(user_id)