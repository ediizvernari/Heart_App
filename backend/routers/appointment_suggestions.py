from typing import List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from backend.crud.appointment_suggestions import update_appointment_suggestion
from backend.database.connection import get_db
from backend.services.appointment_suggestions_service import (
    suggest_appointment,
    get_appointment_suggestion_by_id,
    get_user_appointment_suggestions,
    get_medic_appointment_suggestions,
    delete_suggestion,
)
from backend.schemas.appointment_suggestion_schemas import AppointmentSuggestionCreateSchema, AppointmentSuggestionOutSchema 
from backend.database.sql_models import User, Medic
from backend.services.account_service import get_current_account
from backend.utils.encryption_utils import encrypt_data

router = APIRouter()

@router.post("/users/{user_id}", response_model=AppointmentSuggestionOutSchema)
async def create_appointment_suggestion(user_id: int, appointment_suggestion_payload: AppointmentSuggestionCreateSchema, db: AsyncSession = Depends(get_db), current_medic: Medic = Depends(get_current_account)):
    return await suggest_appointment(db, current_medic, user_id, appointment_suggestion_payload)

@router.get("/mine", response_model=List [AppointmentSuggestionOutSchema])
async def get_my_appointment_suggestions(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_account)):
    return await get_user_appointment_suggestions(db, current_user)

@router.get("/for_medic", response_model=List[AppointmentSuggestionOutSchema])
async def get_my_assigned_users_appointment_suggestions(db: AsyncSession = Depends(get_db), current_medic: Medic = Depends(get_current_account)):
    return await get_medic_appointment_suggestions(db, current_medic)

@router.get("/{appointment_suggestion_id}", response_model = AppointmentSuggestionOutSchema)
async def get_suggestion_by_id(appointment_suggestion_id: int, db: AsyncSession = Depends(get_db)):
    return await get_appointment_suggestion_by_id(db, appointment_suggestion_id)

#TODO: Maybe this function is not needed
@router.delete("/{appointment_suggestion_id}", status_code=204)
async def delete_appointment_suggestion(appointment_suggestion_id: int, db: AsyncSession = Depends(get_db), current_medic: Medic = Depends(get_current_account)):
    await delete_suggestion(db, appointment_suggestion_id, current_medic)

@router.patch("/{appointment_suggestion_id}/status", response_model=AppointmentSuggestionOutSchema)
async def patch_appointment_suggestion_status(appointment_suggestion_id: int, new_appointment_suggestion_status: str = Query(...), db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_account)):
    await update_appointment_suggestion(db, appointment_suggestion_id, {"status": encrypt_data(new_appointment_suggestion_status)})
    return await get_appointment_suggestion_by_id(db, appointment_suggestion_id)
                                              
