from typing            import List
from fastapi           import APIRouter, Depends, Query

from backend.database.sql_models import User, Medic
from backend.features.auth.deps import get_current_account
from backend.features.appointments.deps import get_suggestion_service
from backend.features.appointments.suggestions.appointment_suggestions_service import AppointmentSuggestionService
from backend.features.appointments.suggestions.appointment_suggestion_schemas import (
    AppointmentSuggestionCreateSchema,
    AppointmentSuggestionOutSchema,
)
from backend.utils.encryption_utils import encrypt_data

router = APIRouter()

@router.post("/users/{user_id}", response_model=AppointmentSuggestionOutSchema)
async def create_appointment_suggestion(user_id: int, appointment_suggestion_payload: AppointmentSuggestionCreateSchema, current_medic: Medic = Depends(get_current_account), appointment_suggestion_service: AppointmentSuggestionService = Depends(get_suggestion_service)):
    return await appointment_suggestion_service.suggest_appointment(current_medic.id, user_id, appointment_suggestion_payload)

@router.get("/mine", response_model=List [AppointmentSuggestionOutSchema])
async def get_my_appointment_suggestions(current_user: User = Depends(get_current_account), appointment_suggestion_service: AppointmentSuggestionService = Depends(get_suggestion_service)):
    return await appointment_suggestion_service.get_user_appointment_suggestions(current_user.id)

@router.get("/for_medic", response_model=List[AppointmentSuggestionOutSchema])
async def get_my_assigned_users_appointment_suggestions(current_medic: Medic = Depends(get_current_account), appointment_suggestion_service: AppointmentSuggestionService = Depends(get_suggestion_service)):
    return await appointment_suggestion_service.get_medic_appointment_suggestions(current_medic.id)

@router.get("/{appointment_suggestion_id}", response_model = AppointmentSuggestionOutSchema)
async def get_suggestion_by_id(appointment_suggestion_id: int, appointment_suggestion_service: AppointmentSuggestionService = Depends(get_suggestion_service)):
    return await appointment_suggestion_service.get_appointment_suggestion_by_id(appointment_suggestion_id)

@router.delete("/{appointment_suggestion_id}", status_code=204)
async def delete_appointment_suggestion(appointment_suggestion_id: int, current_medic: Medic = Depends(get_current_account), appointment_suggestion_service: AppointmentSuggestionService = Depends(get_suggestion_service)):
    await appointment_suggestion_service.delete_appointment_suggestion(appointment_suggestion_id)

@router.patch("/{appointment_suggestion_id}/status", response_model=AppointmentSuggestionOutSchema)
async def patch_appointment_suggestion_status(appointment_suggestion_id: int, new_appointment_suggestion_status: str = Query(...), current_user: User = Depends(get_current_account), appointment_suggestion_service: AppointmentSuggestionService = Depends(get_suggestion_service)):
    await appointment_suggestion_service.change_appointment_suggestion_status(appointment_suggestion_id, {"status": encrypt_data(new_appointment_suggestion_status)})
    return await appointment_suggestion_service.get_appointment_suggestion_by_id(appointment_suggestion_id)
                                              
