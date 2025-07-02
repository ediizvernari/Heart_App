import logging
import asyncio
from typing import List
from fastapi import HTTPException

from backend.config import ENCRYPTED_MEDIC_AVAILABILITY_FIELDS
from backend.features.appointments.medic_availability.medic_availability_repository import MedicAvailabilityRepository
from backend.core.utils.encryption_utils import encrypt_fields, decrypt_fields
from .medic_availability_schemas import (
    MedicAvailabilityCreateSchema,
    MedicAvailabilityOutSchema,
    MedicAvailabilityUpdateSchema,
)

class MedicAvailabilityService:
    def __init__(self, medic_availability_repo: MedicAvailabilityRepository):
        self._medic_availability_repo = medic_availability_repo

    async def _map_to_schema(self, availability_id: int) -> MedicAvailabilityOutSchema:
        record = await self._medic_availability_repo.get_by_id(availability_id)
        if not record:
            raise HTTPException(404, "Medic availability not found")

        decrypted=decrypt_fields(record, ENCRYPTED_MEDIC_AVAILABILITY_FIELDS)
        return MedicAvailabilityOutSchema(
            id=record.id,
            medic_id=record.medic_id,
            weekday=decrypted["weekday"],
            start_time=decrypted["start_time"],
            end_time=decrypted["end_time"],
            created_at=record.created_at,
            updated_at=record.updated_at,
        )

    async def get_all_medic_availabilities(self, medic_id: int) -> List[MedicAvailabilityOutSchema]:
        raw_medic_availabilities = await self._medic_availability_repo.get_medic_availabilities(medic_id)
        return await asyncio.gather(*(self._map_to_schema(r.id) for r in raw_medic_availabilities))

    async def create_availability(self, medic_id: int, payload: MedicAvailabilityCreateSchema) -> MedicAvailabilityOutSchema:
        logging.debug(f"Creating availability for medic_id={medic_id}")

        medic_availability_dict = payload.model_dump()
        encrypted_data = encrypt_fields(medic_availability_dict, ENCRYPTED_MEDIC_AVAILABILITY_FIELDS)

        raw_medic_availability = await self._medic_availability_repo.create(
            medic_id=medic_id,
            weekday=encrypted_data["weekday"],
            start_time=encrypted_data["start_time"],
            end_time=encrypted_data["end_time"]
        )
        logging.info(f"Created medic availability with id={raw_medic_availability.id}")
        return await self._map_to_schema(raw_medic_availability.id)

    async def update_medic_availability(self, medic_availability_id: int, medic_availability_payload: MedicAvailabilityUpdateSchema) -> MedicAvailabilityOutSchema:
        logging.debug(f"Updating availability id={medic_availability_id}")

        updates = medic_availability_payload.model_dump(exclude_unset=True)
        if updates:
            encrypted_medic_availability_data = encrypt_fields(updates, ENCRYPTED_MEDIC_AVAILABILITY_FIELDS)
            await self._medic_availability_repo.update(medic_availability_id, encrypted_medic_availability_data)

        return await self._map_to_schema(medic_availability_id)

    async def delete_medic_availability(self, medic_availability_id: int) -> None:
        logging.debug(f"Deleting availability id={medic_availability_id}")
        await self._medic_availability_repo.delete(medic_availability_id)
        logging.info(f"Deleted medic availability with id={medic_availability_id}")