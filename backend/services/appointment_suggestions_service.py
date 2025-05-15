from typing import List, Optional, Union
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException

from backend.crud.appointment_suggestions import(
    create_appointment_suggestion,
    get_encrypted_appointment_suggestion_by_id,
    get_encrypted_user_appointment_suggestions,
    get_encrypted_medic_appointment_suggestions,
    update_appointment_suggestion,
    delete_appointment_suggestion,
)
from backend.crud.medical_service import get_encrypted_medical_service_by_id
from backend.schemas.appointment_suggestion_schemas import(
    AppointmentSuggestionCreateSchema,
    AppointmentSuggestionOutSchema,
)
from backend.database.sql_models import AppointmentSuggestion, User, Medic
from backend.utils.encryption_utils import decrypt_data, encrypt_data, encrypt_fields, decrypt_fields

async def suggest_appointment(
    db: AsyncSession,
    current_medic: Medic,
    user_id: int,
    appointment_suggestion_payload: AppointmentSuggestionCreateSchema,
) -> AppointmentSuggestionOutSchema:
    medical_service = await get_encrypted_medical_service_by_id(
        db, appointment_suggestion_payload.medical_service_id
    )
    if not medical_service or medical_service.medic_id != current_medic.id:
        raise HTTPException(status_code=404, detail="Medical service not found")

    encrypted_reason = (
        encrypt_data(appointment_suggestion_payload.reason)
        if appointment_suggestion_payload.reason is not None
        else None
    )

    encrypted_status = encrypt_data("pending")

    appointment_suggestion_object = await create_appointment_suggestion(
        db,
        user_id=user_id,
        medic_id=current_medic.id,
        medical_service_id=appointment_suggestion_payload.medical_service_id,
        status=encrypted_status,
        reason=encrypted_reason,
    )

    decrypted = decrypt_fields(
        appointment_suggestion_object,
        ["status", "reason"]
    )

    return AppointmentSuggestionOutSchema(
        id=appointment_suggestion_object.id,
        user_id=appointment_suggestion_object.user_id,
        medic_id=appointment_suggestion_object.medic_id,
        medical_service_id=appointment_suggestion_object.medical_service_id,
        status=decrypted["status"],
        reason=decrypted["reason"],
        created_at=appointment_suggestion_object.created_at,
    )



async def get_appointment_suggestion_by_id(
    db: AsyncSession,
    appointment_suggestion_id: int
) -> AppointmentSuggestionOutSchema:
    appointment_suggestion_object = await get_encrypted_appointment_suggestion_by_id(db, appointment_suggestion_id)
    decrypted = decrypt_fields(appointment_suggestion_object, ["status", "reason"])
    return AppointmentSuggestionOutSchema(
        id=appointment_suggestion_object.id,
        user_id=appointment_suggestion_object.user_id,
        medic_id=appointment_suggestion_object.medic_id,
        medical_service_id=appointment_suggestion_object.medical_service_id,  # ← add this
        status=decrypted["status"],
        reason=decrypted["reason"],
        created_at=appointment_suggestion_object.created_at,
    )

async def get_user_appointment_suggestions(db: AsyncSession, current_user: User) -> List[AppointmentSuggestionOutSchema]:
    encrypted_appointment_suggestions = await get_encrypted_user_appointment_suggestions(
        db, current_user.id
    )

    users_appointment_suggestions: List[AppointmentSuggestionOutSchema] = []
    for suggestion in encrypted_appointment_suggestions:
        decrypted_fields = decrypt_fields(suggestion, ["status", "reason"])

        users_appointment_suggestions.append(
            AppointmentSuggestionOutSchema(
                id=suggestion.id,
                user_id=suggestion.user_id,
                medic_id=suggestion.medic_id,
                medical_service_id=suggestion.medical_service_id,   # ← added
                status=decrypted_fields["status"],
                reason=decrypted_fields["reason"],
                created_at=suggestion.created_at,
            )
        )

    return users_appointment_suggestions

async def get_medic_appointment_suggestions(db: AsyncSession, current_medic: Medic) -> List[AppointmentSuggestionOutSchema]:
    encrypted_appointment_suggestions = await get_encrypted_medic_appointment_suggestions(db, current_medic.id)

    medic_appointment_suggestions: List[AppointmentSuggestionOutSchema] = []
    for suggestion in encrypted_appointment_suggestions:
        decrypted_fields = decrypt_fields(suggestion, ["status", "reason"])
        medic_appointment_suggestions.append(AppointmentSuggestionOutSchema(
            id=suggestion.id,
            user_id=suggestion.user_id,
            medic_id=suggestion.medic_id,
            status=decrypted_fields["status"],
            reason=decrypted_fields["reason"],
            created_at=suggestion.created_at
        ))
    
    return medic_appointment_suggestions


#TODO: Maybe delete this function
async def delete_suggestion(db: AsyncSession, appointment_suggestion_id: int, current_medic: Medic) -> None:
    appointment_suggestion_object = await get_encrypted_appointment_suggestion_by_id(db, appointment_suggestion_id)

    if not appointment_suggestion_object or appointment_suggestion_object.medic_id != current_medic.id:
        raise HTTPException(404, "Appointment suggestion not found")
        
    await delete_appointment_suggestion(db, appointment_suggestion_id)
