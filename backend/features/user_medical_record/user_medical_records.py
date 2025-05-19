from typing       import List
from fastapi      import APIRouter, Depends

from backend.database.sql_models import User
from backend.features.auth.deps  import get_current_account
from backend.features.user_medical_record.deps import get_user_medical_record_service
from backend.features.user_medical_record.user_medical_records_schemas import UserMedicalRecordOutSchema
from backend.features.user_medical_record.user_medical_record_service import UserMedicalRecordService

router = APIRouter()

@router.get("/all", response_model=List[UserMedicalRecordOutSchema])
async def get_all_medical_records_for_current_user(current_user: User = Depends(get_current_account), user_medical_record_service: UserMedicalRecordService = Depends(get_user_medical_record_service)):  
    return await user_medical_record_service.get_user_medical_records_by_user_id(current_user.id)

@router.get("/latest", response_model=UserMedicalRecordOutSchema)
async def get_latest_medical_record_for_current_user(current_user: User = Depends(get_current_account), user_medical_record_service: UserMedicalRecordService = Depends(get_user_medical_record_service)):
    return await user_medical_record_service.get_latest_user_medical_record_by_user_id(current_user.id)
