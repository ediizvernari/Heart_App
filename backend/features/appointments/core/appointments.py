from typing import List
from fastapi import APIRouter, Depends, Query
from backend.database.sql_models import User, Medic
from backend.features.auth.deps import get_current_account
from backend.features.appointments.deps import get_appointment_service
from backend.features.appointments.core.appointment_service import AppointmentService
from backend.features.appointments.core.appointment_schemas import (
    AppointmentCreateSchema,
    AppointmentOutSchema,
)

router = APIRouter()

@router.get("/my_appointments", response_model=List[AppointmentOutSchema])
async def get_my_appointments(current_user: User = Depends(get_current_account), appointment_service: AppointmentService = Depends(get_appointment_service)):
    return await appointment_service.get_user_appointments(current_user.id)

@router.get("/medic_appointments", response_model=List[AppointmentOutSchema])
async def get_medic_appointments(current_medic: Medic = Depends(get_current_account), appointment_service: AppointmentService = Depends(get_appointment_service)):
    return await appointment_service.get_medic_appointments(current_medic.id)

@router.post("/", response_model=AppointmentOutSchema)
async def book_appointment(appointment_payload: AppointmentCreateSchema, current_user: User = Depends(get_current_account), appointment_service: AppointmentService = Depends(get_appointment_service)):
    return await appointment_service.create_appointment(current_user.id, appointment_payload)

@router.patch("/{appointment_id}/status", response_model=AppointmentOutSchema)
async def update_appointment_status(appointment_id: int, new_appointment_status: str = Query(..., description="accepted, canceled, completed"), current_account = Depends(get_current_account), appointment_service: AppointmentService = Depends(get_appointment_service)):
    return await appointment_service.change_appointment_status(current_account, appointment_id, new_appointment_status)