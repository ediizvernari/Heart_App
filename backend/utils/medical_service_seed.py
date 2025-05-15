from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.sql_models import MedicalServiceType
from backend.schemas.medical_service_schemas import MedicalServiceTypeSchema
from backend.services.medical_service import create_medical_service_type


CARDIOLOGY_SERVICE_TYPES = [
    "ECG (Electrocardiogram)",
    "Echocardiogram",
    "Exercise Stress Test",
    "Holter Monitor",
    "Cardiac MRI",
    "Cardiac CT Scan",
    "Coronary Angiography",
    "Lipid Panel",
    "Blood Pressure Check",
    "Cardiac Consultation",
    "Cardiac Rehabilitation Session",
    "Pacemaker/Device Check",
    "Event Monitor",
]

async def seed_cardiology_medical_service_types(db: AsyncSession):
        medical_service_type_count = (await db.execute(select(func.count()).select_from(MedicalServiceType))).scalar_one()

        if medical_service_type_count == 0:
            for name in CARDIOLOGY_SERVICE_TYPES:
                try:
                    await create_medical_service_type(medical_service=MedicalServiceTypeSchema(name=name), db=db)
                except Exception:
                    pass

