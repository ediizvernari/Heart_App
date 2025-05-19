from typing import AsyncGenerator
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.connection import get_db

from .location_repository import LocationRepository
from .location_service import LocationService

async def get_location_repo(db: AsyncSession = Depends(get_db)) -> AsyncGenerator[LocationRepository, None]:

    yield LocationRepository(db)

async def get_location_service(location_repo: LocationRepository = Depends(get_location_repo)) -> AsyncGenerator[LocationService, None]:
    yield LocationService(location_repo)