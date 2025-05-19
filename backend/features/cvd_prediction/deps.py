from typing import AsyncGenerator
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.connection import get_db
from backend.features.user_health_data.deps      import get_user_health_data_service
from backend.features.user_health_data.user_health_data_service import UserHealthDataService
from backend.features.user_medical_record.deps  import get_user_medical_record_service
from backend.features.user_medical_record.user_medical_record_service import UserMedicalRecordService
from .cvd_prediction_service import CVDPredictionService

async def get_cvd_prediction_service(db: AsyncSession = Depends(get_db), health_svc: UserHealthDataService = Depends(get_user_health_data_service), record_svc: UserMedicalRecordService = Depends(get_user_medical_record_service)) -> AsyncGenerator[CVDPredictionService, None]:
    yield CVDPredictionService(db, health_svc, record_svc)