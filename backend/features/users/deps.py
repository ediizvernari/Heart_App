from typing import AsyncGenerator
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.connection import get_db
from backend.features.medics.deps import get_medic_repo, get_medic_service
from backend.features.medics.medic_repository import MedicRepository
from backend.features.medics.medic_service import MedicService
from .user_repository import UserRepository
from .user_service    import UserService

async def get_user_repo(db: AsyncSession = Depends(get_db)) -> AsyncGenerator[UserRepository, None]:
    yield UserRepository(db)

async def get_user_service(user_repo: UserRepository = Depends(get_user_repo), medic_service: MedicService = Depends(get_medic_service)):
    yield UserService(user_repo, medic_service)