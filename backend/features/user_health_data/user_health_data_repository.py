from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from backend.crud.utils import create_entity, get_entity_by_field, update_entity_by_id, get_entity_by_id
from backend.database.sql_models import UserHealthData

class UserHealthDataRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_user_health_data(self, user_id: int) -> Optional[UserHealthData]:
        return await get_entity_by_field(self.db, UserHealthData, UserHealthData.user_id == user_id)
    
    async def create_user_health_data(self, user_id: int, **user_health_data_arguments) -> Optional[UserHealthData]:
        return await create_entity(self.db, UserHealthData, user_id=user_id, **user_health_data_arguments)
    
    async def update_user_health_data(self, record_id: int, updated_fields: dict) -> None:
        await update_entity_by_id(self.db, UserHealthData, record_id, updated_fields)
    