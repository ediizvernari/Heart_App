from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from ..utils import user_health_data_utils
from .. import schemas
from ..auth import get_current_account
from ..database import get_db

router = APIRouter()

@router.post("/")
async def create_or_update_user_health_data(
    personal_data: schemas.UserHealthData,
    db: AsyncSession = Depends(get_db),
    current_user: schemas.User = Depends(get_current_account)
):
    user_id = current_user.id 
    await user_health_data_utils.create_or_update_user_health_data(db=db, user_id=user_id, personal_data=personal_data)
    return {"status": "success"}

@router.get("/get_all_users_health_data", response_model=List[schemas.UserHealthData])
async def get_all_users_health_data(db: AsyncSession = Depends(get_db)):
    users_health_data = await user_health_data_utils.get_all_users_health_data(db=db)
    return users_health_data

@router.get("/user_has_health_data")
async def user_has_health_data(db: AsyncSession = Depends(get_db), current_user: schemas.User = Depends(get_current_account)):
    current_user_id = current_user.id
    has_health_data = await user_health_data_utils.check_user_has_health_data(db=db, user_id=current_user_id)
    
    return has_health_data

@router.get("/get_user_health_data_for_user", response_model=schemas.UserHealthData)
async def get_user_health_data_for_user(db:AsyncSession = Depends(get_db), current_user: schemas.User = Depends(get_current_account)):
    current_user_id = current_user.id
    user_health_data = await user_health_data_utils.get_user_health_data_for_user_id(db=db, user_id=current_user_id)
    
    return user_health_data

@router.get("/predict_cvd_probability", response_model=schemas.PredictionResult)
async def get_prediction_for_user(db: AsyncSession = Depends(get_db), current_user: schemas.User = Depends(get_current_account)
):
    prediction = await user_health_data_utils.predict_cvd_probability_for_user(db, current_user.id)
    return {"prediction": prediction}