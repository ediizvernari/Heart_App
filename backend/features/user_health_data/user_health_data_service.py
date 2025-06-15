from fastapi import HTTPException, status

from backend.utils.encryption_utils import (
    encrypt_fields,
    decrypt_health_data_fields_for_user,
)
from backend.features.user_health_data.user_health_data_repository import UserHealthDataRepository
from backend.features.user_health_data.user_health_data_schemas    import UserHealthDataOutSchema, UserHealthDataSchema

class UserHealthDataService:
    def __init__(self, user_health_data_repo: UserHealthDataRepository):
        self._user_health_data_repo = user_health_data_repo

    async def _create_user_health_data(self, user_id: int, data: dict) -> UserHealthDataOutSchema:
        user_health_data_object = await self._user_health_data_repo.create_user_health_data(user_id, **data)
        return await self.get_user_health_data(user_health_data_object.user_id)

    async def _update_user_health_data(self, record_id: int, data: dict) -> None:
        await self._user_health_data_repo.update_user_health_data(record_id, data)

    async def upsert_user_health_data(self, user_id: int, payload: UserHealthDataSchema) -> UserHealthDataOutSchema:
        data = payload.model_dump()
        encrypted = encrypt_fields(data, list(data.keys()))
        existing = await self._user_health_data_repo.get_user_health_data(user_id)

        if existing:
            await self._update_user_health_data(existing.id, encrypted)
        else:
            await self._create_user_health_data(user_id, encrypted)
        
        return await self.get_user_health_data(user_id)
            
    async def check_user_has_health_data(self, user_id: int) -> bool:
        return await self._user_health_data_repo.get_user_health_data(user_id) is not None
    

    async def get_user_health_data(self, user_id: int) -> UserHealthDataOutSchema:
        record = await self._user_health_data_repo.get_user_health_data(user_id)
        if not record:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Health data not found"
            )

        raw = dict(record.__dict__)
        raw.pop("_sa_instance_state", None)

        decrypted = decrypt_health_data_fields_for_user(raw)

        return UserHealthDataOutSchema.model_validate({
            "date_of_birth": decrypted["birth_date"],
            "height_cm": int(decrypted["height"]),
            "weight_kg": int(decrypted["weight"]),
            "cholesterol_level": int(decrypted["cholesterol_level"]),
            "systolic_blood_pressure": int(decrypted["ap_hi"]),
            "diastolic_blood_pressure": int(decrypted["ap_lo"]),
        })
    
    async def get_parsed_user_health_data(self, user_id: int) -> dict:
        encrypted_user_health_data = await self._user_health_data_repo.get_user_health_data(user_id)
        encrypted_user_health_data_dict = dict(encrypted_user_health_data.__dict__)
        encrypted_user_health_data_dict.pop('_sa_instance_state', None)

        decrypted_user_health_data_dict = decrypt_health_data_fields_for_user(encrypted_user_health_data_dict)

        user_data_for_input_feature_build = UserHealthDataSchema(**decrypted_user_health_data_dict)
 
        return {
            "birth_date": user_data_for_input_feature_build.birth_date,
            "height": user_data_for_input_feature_build.height,
            "weight": user_data_for_input_feature_build.weight,
            "cholesterol_level": user_data_for_input_feature_build.cholesterol_level,
            "ap_hi": user_data_for_input_feature_build.ap_hi,
            "ap_lo": user_data_for_input_feature_build.ap_lo,
        }
