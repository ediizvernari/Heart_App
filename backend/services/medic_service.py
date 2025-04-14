from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from ..crud.medic import get_medic_by_email, get_medic_by_id, create_medic
from ..schemas.medic_schemas import MedicCreate
from ..core.auth import create_access_token

async def signup_medic(db: AsyncSession, medic: MedicCreate):
    is_medic_found = await get_medic_by_email(db, email=medic.email)
    if is_medic_found:
        raise HTTPException(status_code=400, detail="A medic with the same email is already registered")
    created_medic = await create_medic(db=db, medic=medic)
    access_token = create_access_token(data={"sub": created_medic.id, "role": "medic"})
    return access_token

async def check_medic_email_availability(db: AsyncSession, email: str):
    is_medic_found = await get_medic_by_email(db, email=email)
    if is_medic_found:
        raise HTTPException(status_code=400, detail="Email already registered")
    return {"available": True}
