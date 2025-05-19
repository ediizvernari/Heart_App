from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future      import select
from sqlalchemy import desc

from backend.crud.utils             import create_entity, list_entities
from backend.database.sql_models    import UserMedicalRecord

class UserMedicalRecordRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_user_medical_record(self, **user_medical_record_arguments) -> UserMedicalRecord:
        return await create_entity(self.db, UserMedicalRecord, **user_medical_record_arguments)

    async def get_all_user_medical_records_by_user(self, user_id: int) -> List[UserMedicalRecord]:
        return await list_entities(self.db, UserMedicalRecord, filters=[UserMedicalRecord.user_id == user_id])
    
    async def get_last_user_medical_record_by_user(self, user_id: int) -> UserMedicalRecord:
        stmt = (
            select(UserMedicalRecord)
            .where(UserMedicalRecord.user_id == user_id)
            .order_by(desc(UserMedicalRecord.created_at))
            .limit(1)
        )
        result = await self.db.execute(stmt)
        return result.scalars().first()
    