from typing import AsyncGenerator
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.connection import get_db
from backend.features.location.deps import get_location_service
from backend.features.location.location_service import LocationService
from backend.features.medics.medic_registry_repository import MedicRegistryRepository
from backend.features.user_health_data.deps import get_user_health_data_service
from backend.features.user_health_data.user_health_data_service import UserHealthDataService
from .medic_repository import MedicRepository
from .medic_service    import MedicService

async def get_medic_repo(db: AsyncSession = Depends(get_db)) -> AsyncGenerator[MedicRepository, None]:
    yield MedicRepository(db)

async def get_medic_registry_repo(db: AsyncSession = Depends(get_db)) -> AsyncGenerator[MedicRegistryRepository, None]:
    yield MedicRegistryRepository(db)

async def get_medic_service(medic_repo: MedicRepository = Depends(get_medic_repo), location_service: LocationService = Depends(get_location_service), user_health_data_service: UserHealthDataService = Depends(get_user_health_data_service), medic_registry_repo: MedicRegistryRepository = Depends(get_medic_registry_repo)) -> AsyncGenerator[MedicService, None]:
    yield MedicService(medic_repo, location_service, user_health_data_service, medic_registry_repo)
