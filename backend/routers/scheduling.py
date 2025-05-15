from datetime import date
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.connection import get_db
from backend.database.sql_models import Medic
from backend.schemas.scheduling_schemas import TimeSlotSchema
from backend.services.scheduling_services import get_current_user_free_time_slots, get_free_time_slots_for_a_day
from backend.services.account_service import get_current_account

router = APIRouter()

@router.get("/medic", response_model=list[TimeSlotSchema])
async def get_medic_free_time_slots(target_date: date = Query(...), time_slot_duration_minutes: int = Query(30), current_medic: Medic = Depends(get_current_account), db: AsyncSession = Depends(get_db)):
    return await get_free_time_slots_for_a_day(db, current_medic.id, target_date, time_slot_duration_minutes)

@router.get("/me/free_time_slots", response_model=list[TimeSlotSchema])
async def get_assigned_medics_free_time_slots_for_user(target_date: date = Query(...), medical_service_id: int | None = Query(None), db: AsyncSession = Depends(get_db), current_user = Depends(get_current_account)):
    print('[DEBUG] Hitting URL: $url')
    return await get_current_user_free_time_slots(db, current_user, target_date, medical_service_id)