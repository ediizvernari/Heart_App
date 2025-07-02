import logging
from typing import List
from fastapi import HTTPException, status

from backend.config import ENCRYPTED_USER_MEDICAL_RECORD_FIELDS
from backend.core.utils.encryption_utils import encrypt_data, encrypt_fields, decrypt_fields
from backend.core.database.sql_models import UserMedicalRecord
from .user_medical_record_repository import UserMedicalRecordRepository
from .user_medical_records_schemas import (
    UserMedicalRecordSchema,
    UserMedicalRecordOutSchema,
)


class UserMedicalRecordService:

    def __init__(self, user_medical_record_repo: UserMedicalRecordRepository):
        self._user_medical_record_repo = user_medical_record_repo

    def _get_user_medical_record_dto(self, user_medical_record: UserMedicalRecord) -> UserMedicalRecordOutSchema:
        decrypted_values = decrypt_fields(user_medical_record, ENCRYPTED_USER_MEDICAL_RECORD_FIELDS)

        return UserMedicalRecordOutSchema(
            id=user_medical_record.id,
            user_id=user_medical_record.user_id,
            created_at=user_medical_record.created_at,
            **decrypted_values
        )

    async def create_user_medical_record(self, user_medical_record_payload: UserMedicalRecordSchema) -> UserMedicalRecordOutSchema:
        user_medical_record_data = user_medical_record_payload.model_dump()
        user_id  = user_medical_record_data.pop("user_id")
        cvd_risk = user_medical_record_data.pop("cvd_risk")

        logging.debug(f"Creating medical record for user_id={user_id}")

        encrypted_user_medical_record_data = encrypt_fields(
            user_medical_record_data,
            ["birth_date", "height", "weight", "cholesterol_level", "ap_hi", "ap_lo"]
        )
        encrypted_user_medical_record_data["cvd_risk"] = encrypt_data(cvd_risk)

        await self._user_medical_record_repo.create(
            user_id=user_id,
            **encrypted_user_medical_record_data
        )

        return await self.get_latest_user_medical_record_by_user_id(user_id)

    async def get_user_medical_records_by_user_id(self, user_id: int) -> List[UserMedicalRecordOutSchema]:
        logging.debug(f"Getting all medical records for user_id={user_id}")

        rows = await self._user_medical_record_repo.get_all_user_medical_records_by_user(user_id)
        return [
            self._get_user_medical_record_dto(rec)
            for rec in rows
        ]

    async def get_latest_user_medical_record_by_user_id(self, user_id: int) -> UserMedicalRecordOutSchema:
        logging.debug(f"Getting latest medical record for user_id={user_id}")

        latest = await self._user_medical_record_repo.get_last_user_medical_record_by_user(user_id)
        if not latest:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail="No user medical record found")

        return self._get_user_medical_record_dto(latest)