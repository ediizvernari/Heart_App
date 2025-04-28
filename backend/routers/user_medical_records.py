from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.sql_models import User
from backend.services.account_service import get_current_account
from ..schemas.user_medical_records_schemas import UserMedicalRecordOutSchema
from ..crud.user_medical_record import get_latest_user_medical_record_for_user, get_user_medical_records_by_user_id
from ..database.connection import get_db

router = APIRouter()

@router.get("/all", response_model=List[UserMedicalRecordOutSchema])
async def get_all_medical_records_for_current_user(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_account)
):
    
    return await get_user_medical_records_by_user_id(db=db, user_id=current_user.id)

@router.get("/latest", response_model=UserMedicalRecordOutSchema)
async def get_latest_medical_record_for_current_user(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_account)
):
    return await get_latest_user_medical_record_for_user(db=db, user_id=current_user.id)
