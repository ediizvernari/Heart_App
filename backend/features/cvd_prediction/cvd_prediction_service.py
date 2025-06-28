from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from sqlalchemy.ext.asyncio import AsyncSession
from backend.features.user_health_data.user_health_data_service   import UserHealthDataService
from backend.features.user_medical_record.user_medical_record_service import UserMedicalRecordService
from backend.features.user_medical_record.user_medical_records_schemas import UserMedicalRecordSchema
from backend.core.utils.data_predictor import (
    build_model_input_features_for_prediction,
    predict_probability_of_having_a_cvd,
)

class CVDPredictionService:
    def __init__(self, db: AsyncSession, user_health_data_service: UserHealthDataService, user_medical_record_service: UserMedicalRecordService):
        self.db = db
        self._user_health_data_service = user_health_data_service
        self._user_medical_record_service = user_medical_record_service
    
    async def predict_cvd_probability_for_user(self, user_id: int) -> float:
        try:
            user_info = await self._user_health_data_service.get_parsed_user_health_data(user_id)

            prediction_features = build_model_input_features_for_prediction(user_info)
            probability = predict_probability_of_having_a_cvd(prediction_features)

            user_medical_record_payload = UserMedicalRecordSchema(
                user_id=user_id,
                birth_date=user_info["birth_date"],
                height=str(user_info["height"]),
                weight=str(user_info["weight"]),
                cholesterol_level=str(user_info["cholesterol_level"]),
                ap_hi=str(user_info["ap_hi"]),
                ap_lo=str(user_info["ap_lo"]),
                cvd_risk=probability,
            )

            await self._user_medical_record_service.create_user_medical_record(user_medical_record_payload)
            print(f"[INFO] Predicted CVD risk probability for user_id={user_id}: {probability}")
            return probability

        except Exception as e:
            print(f"[ERROR] Failed to predict CVD probability for user_id={user_id}: {e}")
            raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")
        