import logging
from fastapi import HTTPException, status

from backend.core.utils.encryption_utils import encrypt_fields, decrypt_fields
from backend.config import ENCRYPTED_USER_HEALTH_DATA_FIELDS
from backend.features.user_health_data.user_health_data_repository import UserHealthDataRepository
from backend.features.user_health_data.user_health_data_schemas import UserHealthDataOutSchema, UserHealthDataSchema

class UserHealthDataService:
    def __init__(self, user_health_data_repo: UserHealthDataRepository):
        self._user_health_data_repo = user_health_data_repo

    async def _create_user_health_data(self, user_id: int, data: dict) -> UserHealthDataOutSchema:
        logging.debug(f"Creating user health data for user_id={user_id}")
        user_health_data_object = await self._user_health_data_repo.create_user_health_data(user_id, **data)
        logging.info(f"Created user health data with id={user_health_data_object.id}")
        
        return await self.get_user_health_data_by_user_id(user_health_data_object.user_id)

    async def _update_user_health_data(self, record_id: int, data: dict) -> None:
        logging.debug(f"Updating user health data record_id={record_id}")
        await self._user_health_data_repo.update_user_health_data(record_id, data)
        logging.info(f"Updated user health data with id={record_id}")

    async def upsert_user_health_data(self, user_id: int, payload: UserHealthDataSchema) -> UserHealthDataOutSchema:
        logging.debug(f"Upserting health data for user_id={user_id}")

        data = payload.model_dump()
        encrypted = encrypt_fields(data, list(data.keys()))
        existing = await self._user_health_data_repo.get_user_health_data(user_id)

        if existing:
            await self._update_user_health_data(existing.id, encrypted)
        else:
            await self._create_user_health_data(user_id, encrypted)

        return await self.get_user_health_data_by_user_id(user_id)

    async def check_user_has_health_data(self, user_id: int) -> bool:
        logging.debug(f"Checking existence of health data for user_id={user_id}")
        return await self._user_health_data_repo.get_user_health_data(user_id) is not None

    async def get_user_health_data_by_user_id(self, user_id: int) -> UserHealthDataOutSchema:
        logging.debug(f"Getting health data for user_id={user_id}")

        record = await self._user_health_data_repo.get_user_health_data(user_id)
        if not record:
            logging.error(f"No health data found for user_id={user_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Health data not found"
            )

        decrypted = decrypt_fields(record, ENCRYPTED_USER_HEALTH_DATA_FIELDS)

        return UserHealthDataOutSchema.model_validate({
            "date_of_birth": decrypted["birth_date"],
            "height_cm": int(decrypted["height"]),
            "weight_kg": int(decrypted["weight"]),
            "cholesterol_level": int(decrypted["cholesterol_level"]),
            "systolic_blood_pressure": int(decrypted["ap_hi"]),
            "diastolic_blood_pressure": int(decrypted["ap_lo"]),
        })

    async def get_parsed_user_health_data(self, user_id: int) -> dict:
        logging.debug(f"Getting parsed health data for user_id={user_id}")

        record = await self._user_health_data_repo.get_user_health_data(user_id)
        if not record:
            logging.error(f"No health data found for user_id={user_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Health data not found"
            )

        decrypted = decrypt_fields(record, ENCRYPTED_USER_HEALTH_DATA_FIELDS)
        parsed = UserHealthDataSchema(**decrypted)

        return {
            "birth_date": parsed.birth_date,
            "height": parsed.height,
            "weight": parsed.weight,
            "cholesterol_level": parsed.cholesterol_level,
            "ap_hi": parsed.ap_hi,
            "ap_lo": parsed.ap_lo,
        }