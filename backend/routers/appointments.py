from typing import List
from datetime import date
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.connection import get_db
from backend.services.appointment_services import (
    get_decrypted_user_appointments,
    get_decrypted_medic_appointments,
    create_appointment,
    change_appointment_status,
)
from backend.schemas.appointment_schemas import AppointmentCreateSchema, AppointmentOutSchema
from backend.database.sql_models import User, Medic
from backend.services.account_service import get_current_account

router = APIRouter()

@router.get("/my_appointments", response_model=List[AppointmentOutSchema])
async def get_my_appointments(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_account)):
    return await get_decrypted_user_appointments(db, current_user)

@router.get("/medic_appointments", response_model=List[AppointmentOutSchema])
async def get_medic_appointments(db: AsyncSession = Depends(get_db), current_medic: Medic = Depends(get_current_account)):
    return await get_decrypted_medic_appointments(db, current_medic.id)

@router.post("/", response_model=AppointmentOutSchema)
async def book_appointment(appointment_payload: AppointmentCreateSchema, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_account)):
    return await create_appointment(db, current_user, appointment_payload)

@router.patch("/{appointment_id}/status", response_model=AppointmentOutSchema)
async def update_appointment_status(appointment_id: int, new_appointment_status: str = Query(..., description="accepted, canceled, completed"), db: AsyncSession = Depends(get_db), current_account = Depends(get_current_account)):
    return await change_appointment_status(db, current_account, appointment_id, new_appointment_status)