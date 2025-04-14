from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.connection import get_db
from ..schemas.user_schemas import UserSchema
from ..schemas.user_health_data_schemas import PredictionResultSchema
from ..services.account_service import get_current_account
from ..services.cvd_prediction_services import predict_cvd_probability_for_user


router = APIRouter()

@router.get("/predict_cvd_probability", response_model=PredictionResultSchema)
async def get_prediction_for_user(db: AsyncSession = Depends(get_db), current_user: UserSchema = Depends(get_current_account)
):
    prediction = await predict_cvd_probability_for_user(db, current_user.id)
    return {"prediction": prediction}