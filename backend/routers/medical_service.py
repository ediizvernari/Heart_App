from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.connection import get_db
from backend.database.sql_models import Medic, MedicalService, MedicalServiceType
from backend.schemas.medical_service_schemas import MedicalServiceOutSchema, MedicalServiceSchema, MedicalServiceTypeOutSchema, MedicalServiceTypeSchema, MedicalServiceUpdateSchema
from backend.services.account_service import get_current_account
from backend.services.medical_service import create_medical_service, delete_medical_service_for_medic, get_all_decrypted_medical_service_types, get_all_decrypted_medical_services_for_medic, get_decrypted_medical_service_by_id, get_decrypted_medical_service_type_by_id, update_medical_service_for_medic


router = APIRouter()


#Medical Service Type routers
@router.get("/medical_service_types", response_model=list[MedicalServiceTypeOutSchema])
async def get_all_medical_service_types(
    db: AsyncSession = Depends(get_db)
):
    return await get_all_decrypted_medical_service_types(db=db)

#TODO: See if this route is needed because it may be not
@router.get("/medical_service_types/{type_id}", response_model=MedicalServiceTypeOutSchema)
async def get_medical_service_type_by_id(
    type_id: int,
    db: AsyncSession = Depends(get_db),
    _: None = Depends(get_current_account)
):
    return await get_decrypted_medical_service_type_by_id(db=db, medical_service_type_id=type_id)


#Medical Service routers
@router.get("/medical_services", response_model=list[MedicalServiceOutSchema])
async def get_all_medical_services_for_medic(
    db: AsyncSession = Depends(get_db),
    current_medic: Medic = Depends(get_current_account)
):
    return await get_all_decrypted_medical_services_for_medic(db=db, medic_id=current_medic.id)   

@router.get("/by_medic/{medic_id}", response_model=list[MedicalServiceOutSchema])
async def get_services_by_medic_id(medic_id: int, db: AsyncSession = Depends(get_db)):
    return await get_all_decrypted_medical_services_for_medic(db=db, medic_id=medic_id)

@router.post("/create_medical_service", status_code=201)
async def create_new_medical_service(
medical_service: MedicalServiceSchema, 
db: AsyncSession = Depends(get_db),
current_medic: Medic = Depends(get_current_account)
):
    return await create_medical_service(db, current_medic=current_medic, medical_service=medical_service)

@router.get("/{medical_service_id}", response_model=MedicalServiceOutSchema)
async def get_medical_service_by_id( medical_service_id: int, db: AsyncSession = Depends(get_db)):
    return await get_decrypted_medical_service_by_id(db, medical_service_id)

@router.patch("/{medical_service_id}", response_model=MedicalServiceOutSchema)
async def update_medical_service(
    medical_service_id: int,
    medical_service_updated_data: MedicalServiceUpdateSchema,
    db: AsyncSession = Depends(get_db),
    current_medic: Medic = Depends(get_current_account)
):
    return await update_medical_service_for_medic(db=db, medic_id=current_medic.id, medical_service_id=medical_service_id, updated_medical_service = medical_service_updated_data)

@router.delete("/{medical_service_id}")
async def remove_medical_service(
    medical_service_id: int,
    db: AsyncSession = Depends(get_db),
    current_medic: Medic = Depends(get_current_account)
):
    await delete_medical_service_for_medic(db=db, medic_id=current_medic.id, medical_service_id=medical_service_id)
    return
