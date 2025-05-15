from datetime import date, time, datetime, timedelta
from typing import List, Tuple
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from backend.crud.medic_availability import (
    create_medic_availability,
    get_encrypted_medic_availabilities,
    get_medic_availability_by_id,
    update_medic_availability_by_id,
)

from backend.schemas.medic_availability_schemas import (
    MedicAvailabilityCreateSchema,
    MedicAvailabilityOutSchema,
    MedicAvailabilityUpdateSchema,
)

from backend.utils.encryption_utils import encrypt_fields, decrypt_fields
from backend.database.sql_models import Medic

async def get_decrypted_medic_availabilities(db: AsyncSession, medic_id: int) -> List[MedicAvailabilityOutSchema]:
    encrypted_availabilities = await get_encrypted_medic_availabilities(db, medic_id)

    decrypted_medic_availabilities: List[MedicAvailabilityOutSchema] = []
    for medic_availability in encrypted_availabilities:
        decrypted_fields = decrypt_fields(medic_availability, ["weekday", "start_time", "end_time"])
        decrypted_medic_availabilities.append(MedicAvailabilityOutSchema(
            id = medic_availability.id,
            medic_id = medic_availability.medic_id,
            weekday = int(decrypted_fields["weekday"]),
            start_time = decrypted_fields["start_time"],
            end_time = decrypted_fields["end_time"],
            created_at = medic_availability.created_at,
            updated_at = medic_availability.updated_at,
        ))
    
    return decrypted_medic_availabilities

#TODO: Rename this function
async def create_availability(db: AsyncSession, current_medic: Medic, medic_availability_payload: MedicAvailabilityCreateSchema):
    encrypted_data = encrypt_fields(medic_availability_payload, ["weekday", "start_time", "end_time"])

    raw_medic_availability = await create_medic_availability(
        db,
        medic_id=current_medic.id,
        weekday=encrypted_data["weekday"],
        start_time=encrypted_data["start_time"],
        end_time=encrypted_data["end_time"]
    )

    decrypted_fields = decrypt_fields(raw_medic_availability, ["weekday", "start_time", "end_time"])

    return MedicAvailabilityOutSchema(
        id=raw_medic_availability.id,
        medic_id=raw_medic_availability.medic_id,
        weekday=int(decrypted_fields["weekday"]),
        start_time=decrypted_fields["start_time"],
        end_time=decrypted_fields["end_time"],
        created_at=raw_medic_availability.created_at,
        updated_at=raw_medic_availability.updated_at
    )

#TODO: Make the update and delete functions for this