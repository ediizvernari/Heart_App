from typing       import List
from fastapi      import APIRouter, Depends

from backend.core.database.sql_models import Medic, User
from backend.features.auth.deps  import get_current_account
from backend.features.user_medical_record.deps import get_user_medical_record_service
from backend.features.user_medical_record.user_medical_records_schemas import UserMedicalRecordOutSchema
from backend.features.user_medical_record.user_medical_record_service import UserMedicalRecordService

router = APIRouter()

# Used by the user to get their own medical records
@router.get("/all", response_model=List[UserMedicalRecordOutSchema])
async def get_all_medical_records_for_current_user(current_user: User = Depends(get_current_account), user_medical_record_service: UserMedicalRecordService = Depends(get_user_medical_record_service)):  
    return await user_medical_record_service.get_user_medical_records_by_user_id(current_user.id)

@router.get("/latest", response_model=UserMedicalRecordOutSchema)
async def get_latest_medical_record_for_current_user(current_user: User = Depends(get_current_account), user_medical_record_service: UserMedicalRecordService = Depends(get_user_medical_record_service)):
    return await user_medical_record_service.get_latest_user_medical_record_by_user_id(current_user.id)

# Used by the medic for a specific user
@router.get("/all/{user_id}", response_model=UserMedicalRecordOutSchema)
async def get_all_medical_records_for_assigned_user(user_id: int, current_medic: Medic = Depends(get_current_account), user_medical_record_service: UserMedicalRecordService = Depends(get_user_medical_record_service)):
    return await user_medical_record_service.get_user_medical_records_by_user_id(user_id)

@router.get("/latest/{user_id}", response_model=UserMedicalRecordOutSchema)
async def get_latest_medical_record_for_assigned_user(user_id: int, current_medic: Medic = Depends(get_current_account), user_medical_record_service: UserMedicalRecordService = Depends(get_user_medical_record_service)):
    return await user_medical_record_service.get_latest_user_medical_record_by_user_id(user_id)
