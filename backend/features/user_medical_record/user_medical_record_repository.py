from typing import List, Optional
from sqlalchemy import desc
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession

from backend.core.repository.generic_repository import GenericRepository
from backend.core.database.sql_models import UserMedicalRecord

class UserMedicalRecordRepository(GenericRepository[UserMedicalRecord]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, UserMedicalRecord)

    async def get_all_user_medical_records_by_user(self, user_id: int) -> List[UserMedicalRecord]:
        return await self.list(filters=[UserMedicalRecord.user_id == user_id])

    async def get_last_user_medical_record_by_user(self, user_id: int) -> Optional[UserMedicalRecord]:
        statement = (
            select(UserMedicalRecord)
            .where(UserMedicalRecord.user_id == user_id)
            .order_by(desc(UserMedicalRecord.created_at))
            .limit(1)
        )
        result = await self.db.execute(statement)
        return result.scalars().first()