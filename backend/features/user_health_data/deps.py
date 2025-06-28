from typing import AsyncGenerator

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from backend.core.database.connection import get_db
from backend.features.user_health_data.user_health_data_repository import UserHealthDataRepository
from backend.features.user_health_data.user_health_data_service import UserHealthDataService

async def get_user_health_data_repo(db: AsyncSession = Depends(get_db)) -> AsyncGenerator[UserHealthDataRepository, None]:
    yield UserHealthDataRepository(db)

async def get_user_health_data_service(repo: UserHealthDataRepository = Depends(get_user_health_data_repo)) -> AsyncGenerator[UserHealthDataService, None]:
    yield UserHealthDataService(repo)