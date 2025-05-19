from typing import AsyncGenerator
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.connection import get_db
from .user_medical_record_repository import UserMedicalRecordRepository
from .user_medical_record_service    import UserMedicalRecordService

async def get_user_medical_record_repo(db: AsyncSession = Depends(get_db),) -> AsyncGenerator[UserMedicalRecordRepository, None]:
    yield UserMedicalRecordRepository(db)

async def get_user_medical_record_service(repo: UserMedicalRecordRepository = Depends(get_user_medical_record_repo)) -> AsyncGenerator[UserMedicalRecordService, None]:
    yield UserMedicalRecordService(repo)