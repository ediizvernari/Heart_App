from typing import List, Optional
from fastapi import HTTPException, status

from backend.database.sql_models import UserMedicalRecord
from backend.utils.encryption_utils import encrypt_fields, encrypt_data, decrypt_fields
from .user_medical_record_repository import UserMedicalRecordRepository
from .user_medical_records_schemas    import (
    UserMedicalRecordSchema,
    UserMedicalRecordOutSchema,
)

class UserMedicalRecordService:
    def __init__(self, user_medical_record_repo: UserMedicalRecordRepository):
        self._user_medical_record_repo = user_medical_record_repo
    
    def _decrypt_user_medical_record_object(self, user_medical_record: UserMedicalRecord) -> UserMedicalRecordOutSchema:
        decrypted = decrypt_fields(user_medical_record, ["birth_date", "height", "weight", "cholesterol_level", "ap_hi", "ap_lo", "cvd_risk"])
        return UserMedicalRecordOutSchema(
            id=user_medical_record.id,
            user_id=user_medical_record.user_id,
            created_at=user_medical_record.created_at,
            **decrypted
        )
    
    async def create_user_medical_record(self, user_medical_record_payload: UserMedicalRecordSchema) -> UserMedicalRecordOutSchema:
        user_medical_record_data = user_medical_record_payload.model_dump()
        user_id  = user_medical_record_data.pop("user_id")
        cvd_risk = user_medical_record_data.pop("cvd_risk")
        encrypted_user_medical_record_data = encrypt_fields(
            user_medical_record_data,
            ["birth_date", "height", "weight", "cholesterol_level", "ap_hi", "ap_lo"]
        )
        encrypted_user_medical_record_data["cvd_risk"] = encrypt_data(cvd_risk)

        user_medical_record_object = await self._user_medical_record_repo.create_user_medical_record(user_id=user_id, **encrypted_user_medical_record_data)

        return self._decrypt_user_medical_record_object(user_medical_record_object)
    
    async def get_user_medical_records_by_user_id(self, user_id: int) -> List[UserMedicalRecordOutSchema]:
        encrypted_user_medical_record_list = await self._user_medical_record_repo.get_all_user_medical_records_by_user(user_id)
        return[self._decrypt_user_medical_record_object(encrypted_user_medical_record) for encrypted_user_medical_record in encrypted_user_medical_record_list]
    
    async def get_latest_user_medical_record_by_user_id(self, user_id: int) -> UserMedicalRecordOutSchema:
        encrypted_user_medical_record = await self._user_medical_record_repo.get_last_user_medical_record_by_user(user_id)
        if not encrypted_user_medical_record:
            raise HTTPException(status_code=404, detail="No user medical record found")
        return self._decrypt_user_medical_record_object(encrypted_user_medical_record)
    