from typing import List
from fastapi import APIRouter, Depends, status
from backend.database.sql_models import Medic
from backend.features.auth.deps import get_current_account
from backend.features.medical_service.deps import get_medical_service_svc
from backend.features.medical_service.medical_service_schemas import (
    MedicalServiceTypeOutSchema,
    MedicalServiceCreateSchema,
    MedicalServiceOutSchema,
    MedicalServiceUpdateSchema,
)
from backend.features.medical_service.medical_service_service import MedicalServiceService


router = APIRouter()


#Medical Service Type routers
@router.get("/medical_service_types", response_model=list[MedicalServiceTypeOutSchema])
async def get_all_medical_service_types(medical_service_service: MedicalServiceService = Depends(get_medical_service_svc)):
    return await medical_service_service.list_medical_service_types()

@router.get("/medical_service_types/{type_id}", response_model=MedicalServiceTypeOutSchema)
async def get_medical_service_type_by_id(medical_service_type_id: int, medical_service_service: MedicalServiceService = Depends(get_medical_service_svc), _: None = Depends(get_current_account)):
    return await medical_service_service.get_medical_service_type_by_id(medical_service_type_id)


#Medical Service routers
@router.get("/medical_services", response_model=List[MedicalServiceOutSchema])
async def get_all_medical_services_for_medic(current_medic: Medic = Depends(get_current_account), medical_service_service: MedicalServiceService = Depends(get_medical_service_svc)):
    return await medical_service_service.list_medical_services_for_medic(current_medic.id)   

@router.get("/by_medic/{medic_id}", response_model=List[MedicalServiceOutSchema])
async def get_all_medical_services_by_medic_id(medic_id: int, medical_service_service: MedicalServiceService = Depends(get_medical_service_svc)):
    return await medical_service_service.list_medical_services_for_medic(medic_id)

@router.post("/create_medical_service", status_code=201)
async def create_new_medical_service(medical_service: MedicalServiceCreateSchema, current_medic: Medic = Depends(get_current_account), medical_service_service: MedicalServiceService = Depends(get_medical_service_svc)):
    return await medical_service_service.create_medical_service_for_medic(current_medic.id, medical_service)

@router.get("/{medical_service_id}", response_model=MedicalServiceOutSchema)
async def get_medical_service_by_id( medical_service_id: int, medical_service_service: MedicalServiceService = Depends(get_medical_service_svc)):
    return await medical_service_service.get_medical_service_by_id(medical_service_id)

@router.patch("/{medical_service_id}", response_model=MedicalServiceOutSchema)
async def update_medical_service(medical_service_id: int, medical_service_updated_data: MedicalServiceUpdateSchema, current_medic: Medic = Depends(get_current_account), medical_service_service: MedicalServiceService = Depends(get_medical_service_svc)):
    return await medical_service_service.update_medical_service_for_medic(current_medic.id, medical_service_id, medical_service_updated_data)

@router.delete("/{medical_service_id}")
async def remove_medical_service(medical_service_id: int, current_medic: Medic = Depends(get_current_account), medical_service_service: MedicalServiceService = Depends(get_medical_service_svc)):
    await medical_service_service.delete_medical_service_for_medic(current_medic.id, medical_service_id)
    return
