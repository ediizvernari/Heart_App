from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException
from ..services.user_health_data_service import get_parsed_user_health_data
from ..utils.data_predictor import build_model_input_features_for_prediction, predict_probability_of_having_a_cvd


async def predict_cvd_probability_for_user(db: AsyncSession, user_id: int) -> float:
    try:
        user_info = await get_parsed_user_health_data(db, user_id)
        
        prediction_features = build_model_input_features_for_prediction(user_info)
        probability_of_developing_a_cvd = predict_probability_of_having_a_cvd(prediction_features)

        print(f"[DEBUG] Probability of developing a CVD for user_id={user_id}: {probability_of_developing_a_cvd}")
        return probability_of_developing_a_cvd

    except Exception as e:
        print(f"[ERROR] Failed to predict CVD risk for user_id={user_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")
    