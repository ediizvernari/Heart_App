import logging
from typing import List
from fastapi import HTTPException

from backend.config import ENCRYPTED_MEDICAL_SERVICE_FIELDS
from backend.core.utils.encryption_utils import encrypt_data, encrypt_fields, decrypt_fields, decrypt_data
from .medical_service_type_repository import MedicalServiceTypeRepository
from .medical_service_repository import MedicalServiceRepository
from .medical_service_schemas import (
    MedicalServiceTypeOutSchema,
    MedicalServiceCreateSchema,
    MedicalServiceOutSchema,
    MedicalServiceUpdateSchema,
)

class MedicalServiceService:
    def __init__(self, medical_service_type_repo: MedicalServiceTypeRepository, medical_service_repo: MedicalServiceRepository):
        self._medical_service_type_repo = medical_service_type_repo
        self._medical_service_repo = medical_service_repo

    async def list_medical_service_types(self) -> List[MedicalServiceTypeOutSchema]:
        logging.debug("Listing all medical service types")

        encrypted_types = await self._medical_service_type_repo.list()
        return [
            MedicalServiceTypeOutSchema.model_validate({
                "id": t.id,
                "name": decrypt_data(t.name),
            })
            for t in encrypted_types
        ]

    async def create_medical_service_type(self, medical_service_type_name: str) -> MedicalServiceTypeOutSchema:
        logging.debug(f"Creating medical service type name={medical_service_type_name}")

        encrypted_name = encrypt_data(medical_service_type_name)
        
        created = await self._medical_service_type_repo.create(name=encrypted_name)
        return await self.get_medical_service_type_by_id(created.id)

    async def get_medical_service_type_by_id(self, medical_service_type_id: int) -> MedicalServiceTypeOutSchema:
        logging.debug(f"Retrieving medical service type id={medical_service_type_id}")

        medical_service_type_object = await self._medical_service_type_repo.get_by_id(medical_service_type_id)
        if not medical_service_type_object:
            logging.error(f"Medical service type {medical_service_type_id} not found")
            raise HTTPException(404, "Medical Service Type not found")
        
        return MedicalServiceTypeOutSchema.model_validate({
            "id": medical_service_type_object.id,
            "name": decrypt_data(medical_service_type_object.name),
        })

    async def list_medical_services_for_medic(self, medic_id: int) -> List[MedicalServiceOutSchema]:
        logging.debug(f"Listing medical services for medic_id={medic_id}")

        encrypted_medical_services = await self._medical_service_repo.list_for_medic(medic_id)
        result: List[MedicalServiceOutSchema] = []
        
        for medical_service in encrypted_medical_services:
            decrypted = decrypt_fields(medical_service, ENCRYPTED_MEDICAL_SERVICE_FIELDS)
            result.append(
                MedicalServiceOutSchema.model_validate({
                    "id": medical_service.id,
                    "medic_id": medical_service.medic_id,
                    "medical_service_type_id": medical_service.medical_service_type_id,
                    "name": decrypted["name"],
                    "price": int(decrypted["price"]),
                    "duration_minutes": int(decrypted["duration_minutes"]),
                })
            )
        return result

    async def create_medical_service_for_medic(self, medic_id: int, medical_service_payload: MedicalServiceCreateSchema) -> MedicalServiceOutSchema:
        logging.debug(f"Creating medical service for medic_id={medic_id}, type_id={medical_service_payload.medical_service_type_id}")

        data = medical_service_payload.model_dump()
        encrypted = encrypt_fields(data, ["name", "price", "duration_minutes"])
        svc = await self._medical_service_repo.create(
            medic_id=medic_id,
            medical_service_type_id=medical_service_payload.medical_service_type_id,
            **encrypted
        )
        decrypted = decrypt_fields(svc, ["name", "price", "duration_minutes"])
        return MedicalServiceOutSchema.model_validate({
            "id": svc.id,
            "medic_id": svc.medic_id,
            "medical_service_type_id": svc.medical_service_type_id,
            "name": decrypted["name"],
            "price": int(decrypted["price"]),
            "duration_minutes": int(decrypted["duration_minutes"]),
        })

    async def get_medical_service_by_id(self, medical_service_id: int) -> MedicalServiceOutSchema:
        logging.debug(f"Retrieving medical service id={medical_service_id}")

        medical_service = await self._medical_service_repo.get_by_id(medical_service_id)
        if not medical_service:
            logging.error(f"Medical service {medical_service_id} not found")
            raise HTTPException(404, "Medical Service not found")
        
        decrypted_medical_service_data = decrypt_fields(medical_service, ["name", "price", "duration_minutes"])
        return MedicalServiceOutSchema.model_validate({
            "id": medical_service.id,
            "medic_id": medical_service.medic_id,
            "medical_service_type_id": medical_service.medical_service_type_id,
            "name": decrypted_medical_service_data["name"],
            "price": int(decrypted_medical_service_data["price"]),
            "duration_minutes": int(decrypted_medical_service_data["duration_minutes"]),
        })

    async def update_medical_service_for_medic(self, medic_id: int, medical_service_id: int, medical_service_update_payload: MedicalServiceUpdateSchema) -> MedicalServiceOutSchema:
        logging.debug(f"Updating medical service id={medical_service_id} for medic_id={medic_id}")

        medical_service = await self._medical_service_repo.get_by_id(medical_service_id)
        if not medical_service or medical_service.medic_id != medic_id:
            logging.error(f"Medical service {medical_service_id} not found or not owned by medic {medic_id}")
            raise HTTPException(404, "Medical Service not found")
        
        updates = medical_service_update_payload.model_dump(exclude_unset=True)
        if updates:
            encrypted = encrypt_fields(updates, list(updates.keys()))
            await self._medical_service_repo.update(medical_service_id, encrypted)
        
        return await self.get_medical_service_by_id(medical_service_id)

    async def delete_medical_service_for_medic(self, medic_id: int, medical_service_id: int):
        logging.debug(f"Deleting medical service id={medical_service_id} for medic_id={medic_id}")

        medical_service_object = await self._medical_service_repo.get_by_id(medical_service_id)
        
        if not medical_service_object or medical_service_object.medic_id != medic_id:
            logging.error(f"Medical service {medical_service_id} not found or not owned by medic {medic_id}")
            raise HTTPException(404, "Medical Service not found")
        
        await self._medical_service_repo.delete(medical_service_id)