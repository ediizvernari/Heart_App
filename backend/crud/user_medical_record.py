from typing import List
from fastapi import HTTPException   #TODO: Maybe move this check into the router file
from sqlalchemy import desc
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.utils.encryption_utils import decrypt_fields, encrypt_data, encrypt_fields
from ..database.sql_models import UserMedicalRecord
from ..schemas.user_medical_records_schemas import UserMedicalRecordOutSchema, UserMedicalRecordSchema

#TODO: Maybe return something else
async def create_user_medical_record(db: AsyncSession, medical_record: UserMedicalRecordSchema):
    encrypted_fields = encrypt_fields(medical_record, ["birth_date", "height", "weight", "cholesterol_level", "ap_hi", "ap_lo"])
    encrypted_cvd_risk = encrypt_data(medical_record.cvd_risk)
    
    new_record = UserMedicalRecord(
        user_id=medical_record.user_id,
        cvd_risk=encrypted_cvd_risk,
        **encrypted_fields
    )

    db.add(new_record)
    await db.commit()
    await db.refresh(new_record)
    return new_record

async def get_user_medical_records_by_user_id(db: AsyncSession, user_id: int) -> List[UserMedicalRecordOutSchema]:
    result = await db.execute(
        select(UserMedicalRecord)
        .where(UserMedicalRecord.user_id == user_id)
    )

    encrypted_user_medical_records = result.scalars().all()

    if not encrypted_user_medical_records:
        return []

    decrypted_user_medical_records = []

    for user_medical_record in encrypted_user_medical_records:
        decrypted_user_medical_record_fields = decrypt_fields(
            user_medical_record, 
            ["birth_date", "height", "weight", "cholesterol_level", "ap_hi", "ap_lo", "cvd_risk"]
        )
        
        decrypted_user_medical_record = UserMedicalRecordOutSchema(
            id=user_medical_record.id,
            user_id=user_medical_record.user_id,
            created_at=user_medical_record.created_at,
            **decrypted_user_medical_record_fields
        )
        decrypted_user_medical_records.append(decrypted_user_medical_record)
    
    return decrypted_user_medical_records

async def get_latest_user_medical_record_for_user(db: AsyncSession, user_id: int) -> UserMedicalRecordOutSchema | None:
    result = await db.execute(
        select(UserMedicalRecord)
        .where(UserMedicalRecord.user_id == user_id)
        .order_by(desc(UserMedicalRecord.created_at))
        .limit(1)
    )

    encrypted_user_medical_record = result.scalars().first()

    if not encrypted_user_medical_record:
        return None
    
    decrypted = decrypt_fields(
        encrypted_user_medical_record,
        ["birth_date", "height", "weight", "cholesterol_level", "ap_hi", "ap_lo", "cvd_risk"]
    )

    return UserMedicalRecordOutSchema(
        id=encrypted_user_medical_record.id,
        user_id=encrypted_user_medical_record.user_id,
        created_at=encrypted_user_medical_record.created_at,
        **decrypted
    )
    