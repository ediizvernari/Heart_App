from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException
from backend.crud.user_medical_record import create_user_medical_record
from backend.schemas.user_medical_records_schemas import UserMedicalRecordSchema
from ..services.user_health_data_service import get_parsed_user_health_data
from ..utils.data_predictor import build_model_input_features_for_prediction, format_cvd_risk_percentage, predict_probability_of_having_a_cvd


async def predict_cvd_probability_for_user(db: AsyncSession, user_id: int) -> float:
    try:
        user_info = await get_parsed_user_health_data(db, user_id)
        
        prediction_features = build_model_input_features_for_prediction(user_info)
        probability_of_developing_a_cvd = predict_probability_of_having_a_cvd(prediction_features)  # THIS returns 0.262

        user_medical_record = UserMedicalRecordSchema(
            user_id=user_id,
            birth_date=user_info["birth_date"],
            height=str(user_info["height"]),
            weight=str(user_info["weight"]),
            cholesterol_level=str(user_info["cholesterol_level"]),
            ap_hi=str(user_info["ap_hi"]),
            ap_lo=str(user_info["ap_lo"]),
            cvd_risk=probability_of_developing_a_cvd
        )

        await create_user_medical_record(db, user_medical_record)

        print(f"[INFO] CVD risk prediction for user_id={user_id}: {probability_of_developing_a_cvd}")

        return probability_of_developing_a_cvd

    except Exception as e:
        print(f"[ERROR] Failed to predict CVD risk for user_id={user_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")
    