from typing import List
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.user import get_user_by_id
from backend.crud.user_medical_record import get_latest_user_medical_record_for_user, get_user_medical_records_by_user_id
from backend.database.sql_models import Medic
from backend.schemas.user_medical_records_schemas import UserMedicalRecordOutSchema


async def get_all_user_medical_records_for_specific_assigned_user(
        db: AsyncSession,
        current_medic: Medic,
        user_id: int
) -> List[UserMedicalRecordOutSchema]:
    
    assigned_user = await get_user_by_id(db, user_id)

    if not assigned_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if assigned_user.medic_id != current_medic.id:
        raise HTTPException(status_code=403, detail="You are not authorized to access this user's medical records")
    
    return await get_user_medical_records_by_user_id(db, user_id)

async def get_latest_user_medical_record_for_specific_assigned_user(
        db: AsyncSession,
        current_medic: Medic,
        user_id: int
) -> UserMedicalRecordOutSchema | None:
    
    assigned_user = await get_user_by_id(db, user_id)

    if not assigned_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if assigned_user.medic_id != current_medic.id:
        raise HTTPException(status_code=403, detail="You are not authorized to access this user's medical records")
    
    return await get_latest_user_medical_record_for_user(db, user_id)