import logging

from sqlalchemy.ext.asyncio import AsyncSession

from backend.features.medical_service.medical_service_type_repository import MedicalServiceTypeRepository
from backend.features.medical_service.medical_service_repository import MedicalServiceRepository
from backend.features.medical_service.medical_service_service import MedicalServiceService


CARDIOLOGY_SERVICE_TYPES = [
    "ECG (Electrocardiogram)",
    "Echocardiogram",
    "Exercise Stress Test",
    "Cardiac MRI",
    "Cardiac CT Scan",
    "Cardiac Consultation",
    "Cardiac Rehabilitation Session",
    "Pacemaker/Device Check",
]

async def seed_cardiology_medical_service_types(db: AsyncSession):
    type_repo = MedicalServiceTypeRepository(db)
    service_repo = MedicalServiceRepository(db)
    service = MedicalServiceService(type_repo, service_repo)

    if await type_repo.count() > 0:
        logging.info("MedicalServiceType table already populated, skipping.")
        return

    for name in CARDIOLOGY_SERVICE_TYPES:
        try:
            await service.create_medical_service_type(name)
        except Exception as e:
            logging.error(f"  x failed to seed {name}: {e}")
            await db.rollback()
