from typing import List
from fastapi import HTTPException


from backend.utils.encryption_utils import encrypt_fields, decrypt_fields, decrypt_data
from .medical_service_repository import MedicalServiceRepository
from .medical_service_schemas import (
    MedicalServiceTypeOutSchema,
    MedicalServiceCreateSchema,
    MedicalServiceOutSchema,
    MedicalServiceUpdateSchema,
)

class MedicalServiceService:
    def __init__(self, medical_service_repo: MedicalServiceRepository):
        self.medical_service_repo=medical_service_repo

    #Medical Service Type Methods
    async def list_medical_service_types(self) -> List[MedicalServiceTypeOutSchema]:
        encrypted_medical_service_types = await self.medical_service_repo.list_medical_service_types()
        return [
            MedicalServiceTypeOutSchema.model_validate({
                "id": encrypted_medical_service_type.id,
                "name": decrypt_data(encrypted_medical_service_type.name),
            })
            for encrypted_medical_service_type in encrypted_medical_service_types
        ]
    
    #TODO: See if this function is needed
    async def get_medical_service_type_by_id(self, medical_service_type_id) -> MedicalServiceTypeOutSchema:
        medical_service_type_obj = await self.medical_service_repo.get_medical_service_type_by_id(medical_service_type_id)
        if not medical_service_type_obj:
            raise HTTPException(404, "Medical Service Type not found!")
        return MedicalServiceTypeOutSchema.model_validate({
            "id": medical_service_type_obj.id,
            "name": decrypt_data(medical_service_type_obj.name),
        })
    

    #Medical Service Methods
    async def list_medical_services_for_medic(self, medic_id: int) -> List[MedicalServiceOutSchema]:
        encrypted_medical_services = await self.medical_service_repo.list_medical_services_for_medic(medic_id)
        decrypted_medical_services: List[MedicalServiceOutSchema] = []

        for medical_service in encrypted_medical_services:
            decrypted_data = decrypt_fields(medical_service, ["name", "price", "duration_minutes"])
            decrypted_medical_services.append(MedicalServiceOutSchema.model_validate({
                "id": medical_service.id,
                "medic_id": medical_service.medic_id,
                "medical_service_type_id": medical_service.medical_service_type_id,
                "name": decrypted_data["name"],
                "price": int(decrypted_data["price"]),
                "duration_minutes": decrypted_data["duration_minutes"],
            }))
        return decrypted_medical_services
    
    async def create_medical_service_for_medic(self, medic_id: int, medical_service_payload: MedicalServiceCreateSchema) -> MedicalServiceOutSchema:
        encrypted_data = encrypt_fields(medical_service_payload, ["name", "price", "duration_minutes"])
        
        medical_service = await self.medical_service_repo.create_medical_service(
            medic_id=medic_id,
            medical_service_type_id=medical_service_payload.medical_service_type_id,
            **encrypted_data
        )
        decrypted_medical_service_fields = decrypt_fields(medical_service, ["name", "price", "duration_minutes"])
        return MedicalServiceOutSchema.model_validate({
            "id": medical_service.id,
            "medic_id": medical_service.medic_id,
            "medical_service_type_id": medical_service.medical_service_type_id,
            "name": decrypted_medical_service_fields["name"],
            "price": int(decrypted_medical_service_fields["price"]),
            "duration_minutes": int(decrypted_medical_service_fields["duration_minutes"]),
        })
    
    async def get_medical_service_by_id(self, medical_service_id: int) -> MedicalServiceOutSchema:
        medical_service_obj = await self.medical_service_repo.get_medical_service_by_id(medical_service_id)
        if not medical_service_obj:
            raise HTTPException(404, "Service not found")
        decrypted_data = decrypt_fields(medical_service_obj, ["name", "price", "duration_minutes"])
        return MedicalServiceOutSchema.model_validate({
            "id": medical_service_obj.id,
            "medic_id": medical_service_obj.medic_id,
            "medical_service_type_id": medical_service_obj.medical_service_type_id,
            "name": decrypted_data["name"],
            "price": int(decrypted_data["price"]),
            "duration_minutes": int(decrypted_data["duration_minutes"]),
        })
    
    async def update_medical_service_for_medic(self, medic_id: int, medical_service_id: int, medical_service_update_payload: MedicalServiceUpdateSchema) -> MedicalServiceOutSchema:
        medical_service_object = await self.medical_service_repo.get_medical_service_by_id(medical_service_id)
        if not medical_service_object or medical_service_object.medic_id != medic_id:
            raise HTTPException(404, "Service not found")
        updates = medical_service_update_payload.model_dump(exclude_unset=True)
        if updates:
            encrypted = encrypt_fields(updates, list(updates.keys()))
            await self.medical_service_repo.update_medical_service(medical_service_id, encrypted)
        return await self.get_medical_service_by_id(medical_service_id)

    async def delete_medical_service_for_medic(self, medic_id: int, medical_service_id: int):
        medical_service_object = await self.medical_service_repo.get_medical_service_by_id(medical_service_id)
        if not medical_service_object or medical_service_object.medic_id != medic_id:
            raise HTTPException(404, "Medical Service not found")
        
        await self.medical_service_repo.delete_medical_service_by_id(medical_service_id)
