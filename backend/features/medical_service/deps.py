from typing import AsyncGenerator
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.connection import get_db
from .medical_service_type_repository import MedicalServiceTypeRepository
from .medical_service_repository import MedicalServiceRepository
from .medical_service_service import MedicalServiceService

async def get_medical_service_type_repo(db: AsyncSession = Depends(get_db)) -> AsyncGenerator[MedicalServiceTypeRepository, None]:
    yield MedicalServiceTypeRepository(db)


async def get_medical_service_repo(db: AsyncSession = Depends(get_db)) -> AsyncGenerator[MedicalServiceRepository, None]:
    yield MedicalServiceRepository(db)


async def get_medical_service_svc(type_repo: MedicalServiceTypeRepository = Depends(get_medical_service_type_repo), service_repo: MedicalServiceRepository = Depends(get_medical_service_repo)) -> AsyncGenerator[MedicalServiceService, None]:
    yield MedicalServiceService(type_repo, service_repo)
