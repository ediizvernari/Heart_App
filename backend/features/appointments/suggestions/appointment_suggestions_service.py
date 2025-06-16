import asyncio
from typing import List
from fastapi import HTTPException

from backend.config import ENCRYPTED_APPOINTMENT_SUGGESTION_FIELDS
from backend.features.appointments.suggestions.appointment_suggestions_repository import AppointmentSuggestionRepository
from backend.features.medical_service.medical_service_service import MedicalServiceService
from backend.utils.encryption_utils import encrypt_fields, decrypt_fields
from .appointment_suggestion_schemas import AppointmentSuggestionCreateSchema, AppointmentSuggestionOutSchema

class AppointmentSuggestionService:
    def __init__(self, suggestion_repository: AppointmentSuggestionRepository, medical_service_service: MedicalServiceService):
        self._suggestion_repository=suggestion_repository
        self._medical_service_service=medical_service_service

    async def _map_suggestion_to_schema(self, suggestion_id: int) -> AppointmentSuggestionOutSchema:
        appointment_suggestion_object = await self._suggestion_repository.get_by_id(suggestion_id)
        if not appointment_suggestion_object:
            raise HTTPException(404, "Appointment suggestion not found")

        decrypted_values=decrypt_fields(appointment_suggestion_object, ENCRYPTED_APPOINTMENT_SUGGESTION_FIELDS)
        return AppointmentSuggestionOutSchema(
            id=appointment_suggestion_object.id,
            user_id=appointment_suggestion_object.user_id,
            medic_id=appointment_suggestion_object.medic_id,
            medical_service_id=appointment_suggestion_object.medical_service_id,
            status=decrypted_values["status"],
            reason=decrypted_values["reason"],
            created_at=appointment_suggestion_object.created_at,
        )

    async def get_user_appointment_suggestions(self, user_id: int) -> List[AppointmentSuggestionOutSchema]:
        suggestion_records = await self._suggestion_repository.get_user_appointment_suggestions(user_id)
        return await asyncio.gather(*(self._map_suggestion_to_schema(r.id) for r in suggestion_records))

    async def get_medic_appointment_suggestions(self, medic_id: int) -> List[AppointmentSuggestionOutSchema]:
        suggestion_records = await self._suggestion_repository.get_medic_appointment_suggestions(medic_id)
        return await asyncio.gather(*(self._map_suggestion_to_schema(r.id) for r in suggestion_records))
    
    async def get_appointment_suggestion_by_id(self, suggestion_id: int) -> AppointmentSuggestionOutSchema:
        return await self._map_suggestion_to_schema(suggestion_id)

    async def suggest_appointment(self, medic_id: int, user_id: int, payload: AppointmentSuggestionCreateSchema) -> AppointmentSuggestionOutSchema:
        print(f"[INFO] Creating appointment suggestion for medic_id={medic_id}, user_id={user_id}")

        medical_service=await self._medical_service_service.get_medical_service_by_id(payload.medical_service_id)
        if not medical_service or medical_service.medic_id!=medic_id:
            raise HTTPException(404, "Medical service not found")

        raw_payload=payload.model_dump()
        encrypted_fields=encrypt_fields({
            "status":"pending",
            "reason":raw_payload.get("reason")
        }, ENCRYPTED_APPOINTMENT_SUGGESTION_FIELDS)

        new_suggestion=await self._suggestion_repository.create(
            user_id=user_id,
            medic_id=medic_id,
            medical_service_id=payload.medical_service_id,
            status=encrypted_fields["status"],
            reason=encrypted_fields["reason"],
        )
        return await self._map_suggestion_to_schema(new_suggestion.id)

    async def change_appointment_suggestion_status(self, suggestion_id: int, new_status: str) -> AppointmentSuggestionOutSchema:
        print(f"[INFO] Changing appointment suggestion status id={suggestion_id} to {new_status}")

        suggestion_record = await self._suggestion_repository.get_by_id(suggestion_id)
        if not suggestion_record:
            print(f"[ERROR] Appointment suggestion {suggestion_id} not found")
            raise HTTPException(404, "Appointment suggestion not found")

        decrypted = decrypt_fields(suggestion_record, ENCRYPTED_APPOINTMENT_SUGGESTION_FIELDS)
        old_reason = decrypted.get("reason")

        encrypted_fields = encrypt_fields(
            {
                "status": new_status,
                "reason": old_reason
            },
            ENCRYPTED_APPOINTMENT_SUGGESTION_FIELDS
        )

        await self._suggestion_repository.update(suggestion_id, encrypted_fields)
        return await self._map_suggestion_to_schema(suggestion_id)

    async def delete_appointment_suggestion(self, suggestion_id: int) -> None:
        print(f"[INFO] Deleting appointment suggestion id={suggestion_id}")
        await self._suggestion_repository.delete(suggestion_id)