from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from backend.core.repository.generic_repository import GenericRepository
from backend.core.database.sql_models import UserHealthData

class UserHealthDataRepository(GenericRepository[UserHealthData]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, UserHealthData)

    async def get_user_health_data(self, user_id: int) -> Optional[UserHealthData]:
        statement = select(self.model).where(self.model.user_id == user_id)
        result = await self.db.execute(statement)
        return result.scalar_one_or_none()

    async def create_user_health_data(self, user_id: int, **user_health_data_arguments) -> UserHealthData:
        return await self.create(user_id=user_id, **user_health_data_arguments)

    async def update_user_health_data(self, record_id: int, updated_fields: dict) -> None:
        await self.update(record_id, updated_fields)