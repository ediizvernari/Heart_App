from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from ..schemas.user_schemas import UserSchema
from ..schemas.user_health_data_schemas import UserHealthDataSchema
from ..crud.user_health_data import check_user_has_health_data
from ..services.account_service import get_current_account
from ..services.user_health_data_service import create_or_update_user_health_data_for_user, get_all_users_health_data, get_user_health_data_for_user_id
from ..database.connection import get_db

router = APIRouter()

@router.post("/create_or_update_user_health_data")
async def create_or_update_user_health_data(
    personal_data: UserHealthDataSchema,
    db: AsyncSession = Depends(get_db),
    current_user: UserSchema = Depends(get_current_account)
):
    await create_or_update_user_health_data_for_user(db=db, user_id=current_user.id , user_health_data=personal_data)
    return {"status": "success"}

@router.get("/get_all_users_health_data", response_model=List[UserHealthDataSchema])
async def get_all_users_health_data(db: AsyncSession = Depends(get_db)):
    users_health_data = await get_all_users_health_data(db=db)
    return users_health_data

@router.get("/user_has_health_data")
async def user_has_health_data(db: AsyncSession = Depends(get_db), current_user: UserSchema = Depends(get_current_account)):
    has_health_data = await check_user_has_health_data(db=db, user_id=current_user.id)
    
    return has_health_data

@router.get("/get_user_health_data_for_user", response_model=UserHealthDataSchema)
async def get_user_health_data_for_user(db:AsyncSession = Depends(get_db), current_user: UserSchema = Depends(get_current_account)):
    user_health_data = await get_user_health_data_for_user_id(db=db, user_id=current_user.id)
    
    return user_health_data
