from typing import List
from fastapi import HTTPException

from backend.utils.encryption_utils import encrypt_fields, decrypt_fields
from .medic_availability_repository import MedicAvailabilityRepository
from .medic_availability_schemas    import MedicAvailabilityCreateSchema, MedicAvailabilityOutSchema, MedicAvailabilityUpdateSchema

class MedicAvailabilityService:
    def __init__(self, medic_availability_repo: MedicAvailabilityRepository):
        self._medic_availability_repo = medic_availability_repo

    async def _get_medic_availability_by_id(self, medic_availability_id: int) -> MedicAvailabilityOutSchema:
        encrypted_medic_availability = await self._medic_availability_repo.get_medic_availability_by_id(medic_availability_id)
        if not encrypted_medic_availability:
            raise HTTPException(404, "Medic Availability not found")
        
        decrypted_medic_availability_data = decrypt_fields(encrypted_medic_availability, ["weekday", "start_time", "end_time"])
        return MedicAvailabilityOutSchema.model_validate({
            "id": encrypted_medic_availability.id,
            "medic_id": encrypted_medic_availability.medic_id,
            "weekday": decrypted_medic_availability_data["weekday"],
            "start_time": decrypted_medic_availability_data["start_time"],
            "end_time": decrypted_medic_availability_data["end_time"],
            "created_at": encrypted_medic_availability.created_at,
            "updated_at": encrypted_medic_availability.updated_at,
        })

    async def get_all_medic_availabilities(self, medic_id: int) -> List[MedicAvailabilityOutSchema]:
        encrypted_availabilities = await self._medic_availability_repo.get_encrypted_medic_availabilities(medic_id)
        return [await self._get_medic_availability_by_id(encrypted_availability.id) for encrypted_availability in encrypted_availabilities]

    async def create_availability(self, medic_id: int, medic_availability_payload: MedicAvailabilityCreateSchema):
        encrypted_data = encrypt_fields(medic_availability_payload, ["weekday", "start_time", "end_time"])

        raw_medic_availability = await self._medic_availability_repo.create_medic_availability(
            medic_id=medic_id,
            weekday=encrypted_data["weekday"],
            start_time=encrypted_data["start_time"],
            end_time=encrypted_data["end_time"]
        )

        return await self._get_medic_availability_by_id(raw_medic_availability.id)

    async def update_medic_availability(self, medic_availability_id: int, medic_availability_payload: MedicAvailabilityUpdateSchema) -> MedicAvailabilityOutSchema:
        updates = medic_availability_payload.model_dump(exclude_unset=True)
        if updates:
            encrypted_medic_availability_data = encrypt_fields(updates, list(updates.keys()))
            await self._medic_availability_repo.update_medic_availability_by_id(medic_availability_id, encrypted_medic_availability_data)
        
        return await self._get_medic_availability_by_id(medic_availability_id)
    
    async def delete_medic_availability(self, medic_availability_id: int) -> None:
        await self._medic_availability_repo.delete_medic_availability_by_id(medic_availability_id)
