from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.medic_availability import delete_medic_availability_by_id
from backend.database.connection import get_db
from backend.database.sql_models import Medic
from backend.schemas.medic_availability_schemas import MedicAvailabilityCreateSchema, MedicAvailabilityOutSchema
from backend.services.medic_availability_services import create_availability, get_decrypted_medic_availabilities
from backend.services.account_service import get_current_account

router = APIRouter()

@router.get("/all", response_model=List[MedicAvailabilityOutSchema])
async def get_medical_availabilities_for_medic(current_medic: Medic = Depends(get_current_account), db: AsyncSession = Depends(get_db)):
    return await get_decrypted_medic_availabilities(db, current_medic.id)

@router.post("/create", response_model=MedicAvailabilityOutSchema)
async def add_medic_availability_for_medic(medic_availability_payoad: MedicAvailabilityCreateSchema, db: AsyncSession = Depends(get_db), current_medic: Medic = Depends(get_current_account)):
    return await create_availability(db, current_medic, medic_availability_payoad)

@router.delete("/{medic_availability_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_availability_for_medic(medic_availability_id: int, db: AsyncSession = Depends(get_db), current_medic: Medic = Depends(get_current_account)):
    await delete_medic_availability_by_id(db, medic_availability_id)
    return