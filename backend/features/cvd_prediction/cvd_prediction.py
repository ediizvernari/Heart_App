from fastapi import APIRouter, Depends
from backend.core.database.sql_models import User
from backend.features.auth.deps import get_current_account
from backend.features.cvd_prediction.deps import get_cvd_prediction_service
from backend.features.cvd_prediction.cvd_prediction_schema import PredictionResultSchema
from backend.features.cvd_prediction.cvd_prediction_service import CVDPredictionService


router = APIRouter()

@router.get("/predict_cvd_probability", response_model=PredictionResultSchema)
async def get_prediction_for_user(current_user: User = Depends(get_current_account), cvd_prediction_service: CVDPredictionService = Depends(get_cvd_prediction_service)):
    cvd_probability = await cvd_prediction_service.predict_cvd_probability_for_user(current_user.id)
    return {"prediction": cvd_probability}