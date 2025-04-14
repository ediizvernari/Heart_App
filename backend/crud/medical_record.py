from fastapi import HTTPException   #TODO: Maybe move this check into the router file
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from ..database.sql_models import MedicalRecord
from ..schemas.medical_records_schemas import MedicalRecordCreate, MedicalRecord

async def create_medical_record(db: AsyncSession, record: MedicalRecordCreate):
    db_record = MedicalRecord(**record.model_dump())
    db.add(db_record)
    await db.commit()
    await db.refresh(db_record)
    return db_record

async def get_medical_record(db: AsyncSession, record_id: int):
    result = await db.execute(select(MedicalRecord).filter(MedicalRecord.id == record_id))
    return result.scalars().first()
