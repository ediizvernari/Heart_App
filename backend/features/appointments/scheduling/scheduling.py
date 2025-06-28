from datetime import date
from typing import List

from fastapi import APIRouter, Depends, Query

from backend.core.database.sql_models import Medic
from backend.features.auth.deps import get_current_account
from backend.features.appointments.deps import get_scheduling_service
from backend.features.appointments.scheduling.scheduling_service import SchedulingService
from backend.features.appointments.scheduling.scheduling_schemas import TimeSlotSchema

router = APIRouter()

@router.get("/medic", response_model=List[TimeSlotSchema])
async def get_medic_free_time_slots(target_date: date = Query(...), time_slot_duration_minutes: int = Query(30), current_medic: Medic = Depends(get_current_account), scheduling_service: SchedulingService = Depends(get_scheduling_service)):
    return await scheduling_service.get_free_time_slots_for_a_day(current_medic.id, target_date, time_slot_duration_minutes)

@router.get("/me/free_time_slots", response_model=List[TimeSlotSchema])
async def get_assigned_medics_free_time_slots_for_user(target_date: date = Query(...), medical_service_id: int | None = Query(None), current_user = Depends(get_current_account), scheduling_service: SchedulingService = Depends(get_scheduling_service)):
    return await scheduling_service.get_current_user_free_time_slots(current_user, target_date, medical_service_id)