from sqlalchemy.ext.asyncio import AsyncSession

from backend.features.medical_service.medical_service_repository import MedicalServiceRepository
from backend.features.medical_service.medical_service_service import MedicalServiceService


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
    repo    = MedicalServiceRepository(db)
    service = MedicalServiceService(repo)

    if await repo.count() > 0:
        print("MedicalServiceType table already populated, skipping.")
        return

    for name in CARDIOLOGY_SERVICE_TYPES:
        try:
            await service.create_medical_service_type(name)
        except Exception as e:
            print(f"  × failed to seed {name}: {e}")
            await db.rollback()
