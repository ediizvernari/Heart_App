from typing import List
from fastapi import HTTPException
from datetime import datetime

from backend.features.medical_service.medical_service_service import MedicalServiceService
from backend.utils.encryption_utils import encrypt_data, encrypt_fields, decrypt_fields
from .appointment_suggestions_repository import AppointmentSuggestionRepository
from .appointment_suggestion_schemas    import AppointmentSuggestionCreateSchema, AppointmentSuggestionOutSchema

class AppointmentSuggestionService:
    def __init__(self, appointment_suggestion_repo: AppointmentSuggestionRepository, medical_service_service: MedicalServiceService):
        self._appointment_suggestion_repo = appointment_suggestion_repo
        self._medical_service_service = medical_service_service

    async def get_appointment_suggestion_by_id(self, appointment_suggestion_id: int) -> AppointmentSuggestionOutSchema:
        appointment_suggestion_object = await self._appointment_suggestion_repo.get_appointment_suggestion_by_id(appointment_suggestion_id)
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

    async def suggest_appointment(self, medic_id: int, user_id: int, appointment_suggestion_payload: AppointmentSuggestionCreateSchema) -> AppointmentSuggestionOutSchema:
        medical_service = await self._medical_service_service.get_medical_service_by_id(appointment_suggestion_payload.medical_service_id)
        if not medical_service or medical_service.medic_id != medic_id:
            raise HTTPException(status_code=404, detail="Medical service not found")

        encrypted_reason = (
            encrypt_data(appointment_suggestion_payload.reason)
            if appointment_suggestion_payload.reason is not None
            else None
        )

        encrypted_status = encrypt_data("pending")

        encrypted_appointment_suggestion_object = await self._appointment_suggestion_repo.create_appointment_suggestion(
            user_id=user_id,
            medic_id=medic_id,
            medical_service_id=appointment_suggestion_payload.medical_service_id,
            status=encrypted_status,
            reason=encrypted_reason,
        )
        return await self.get_appointment_suggestion_by_id(encrypted_appointment_suggestion_object.id)

    async def get_user_appointment_suggestions(self, user_id: int) -> List[AppointmentSuggestionOutSchema]:
        encrypted_appointment_suggestions = await self._appointment_suggestion_repo.get_user_appointment_suggestions(user_id)
        return [await self.get_appointment_suggestion_by_id(encrypted_appointment_suggestion.id) for encrypted_appointment_suggestion in encrypted_appointment_suggestions]

    async def get_medic_appointment_suggestions(self, medic_id: int) -> List[AppointmentSuggestionOutSchema]:
        encrypted_appointment_suggestions = await self._appointment_suggestion_repo.get_medic_appointment_suggestions(medic_id)
        return [await self.get_appointment_suggestion_by_id(encrypted_appointment_suggestion.id) for encrypted_appointment_suggestion in encrypted_appointment_suggestions]

    async def change_appointment_suggestion_status(self, appointment_suggestion_id: int, new_status: str) -> AppointmentSuggestionOutSchema:
        encrypted_data = encrypt_fields({"status": new_status}, ["status"])
        await self._appointment_suggestion_repo.update_appointment_suggestion(appointment_suggestion_id, encrypted_data)
        return await self.get_appointment_suggestion_by_id(appointment_suggestion_id)
    
    async def accept(self, appointment_suggestion_id: int) -> AppointmentSuggestionOutSchema:
        return await self.change_appointment_suggestion_status(appointment_suggestion_id, "accepted")

    async def reject(self, appointment_suggestion_id: int) -> AppointmentSuggestionOutSchema:
        return await self.change_appointment_suggestion_status(appointment_suggestion_id, "rejected")

    async def delete_appointment_suggestion(self, appointment_suggestion_id: int) -> None:
        await self._appointment_suggestion_repo.delete_appointment_suggestion(appointment_suggestion_id)
