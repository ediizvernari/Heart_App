import asyncio
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.connection import get_db
from backend.features.medical_service.medical_service_repository import MedicalServiceRepository
from backend.features.medical_service.medical_service_schemas    import MedicalServiceTypeCreateSchema


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
        repo = MedicalServiceRepository(db)

        count = await repo.count()
        if count > 0:
            print("MedicalServiceType table already populated, skipping.")
            return

        for name in CARDIOLOGY_SERVICE_TYPES:
            try:
                payload = MedicalServiceTypeCreateSchema(name=name)
                await repo.create_medical_service_type(payload)
            except Exception as e:
                print(f"  × failed to seed {name}: {e}")
