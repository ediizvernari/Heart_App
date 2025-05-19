from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from backend.database.sql_models import User
from backend.features.auth.deps                         import get_current_account
from backend.features.user_health_data.deps             import get_user_health_data_service
from backend.features.user_health_data.user_health_data_schemas import (
    UserHealthDataSchema,
    UserHealthDataOutSchema,
)
from backend.features.user_health_data.user_health_data_service import UserHealthDataService

router = APIRouter()

@router.post("/create_or_update_user_health_data", response_model=UserHealthDataOutSchema)
async def create_or_update_user_health_data(personal_data: UserHealthDataSchema, current_user: User = Depends(get_current_account), user_health_data_service: UserHealthDataService = Depends(get_user_health_data_service)):
    return await user_health_data_service.upsert_user_health_data(current_user.id, personal_data)

@router.get("/user_has_health_data", response_model=bool)
async def user_has_health_data(current_user: User = Depends(get_current_account), user_health_data_service: UserHealthDataService = Depends(get_user_health_data_service)):
    return await user_health_data_service.check_user_has_health_data(current_user.id)

@router.get("/get_user_health_data_for_user", response_model=UserHealthDataOutSchema)
async def get_user_health_data_for_user(current_user: User = Depends(get_current_account), user_health_data_service: UserHealthDataService = Depends(get_user_health_data_service)):
    return await user_health_data_service.get_user_health_data(user_id=current_user.id)