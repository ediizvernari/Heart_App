from typing import List, Optional, Any
from sqlalchemy import func
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.utils import (
    create_entity,
    get_entity_by_field,
    list_entities,
    update_entity_by_id,
    delete_entity_by_id,
    get_entity_by_id,
)
from backend.database.sql_models import MedicalServiceType, MedicalService

class MedicalServiceRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    #Medical Service Type Methods
    async def count(self) -> int:
        stmt = select(func.count()).select_from(MedicalServiceType)
        result = await self.db.execute(stmt)
        return result.scalar_one()

    async def create_medical_service_type(self, medical_service_type_name: str) -> MedicalServiceType:
        return await create_entity(self.db, MedicalServiceType, name=medical_service_type_name)
    
    async def get_medical_service_type_by_id(self, medical_service_type_id: int) -> Optional[MedicalServiceType]:
        return await get_entity_by_id(self.db, MedicalServiceType, medical_service_type_id)
    
    async def get_medical_service_type_by_name(self, medical_service_type_name: str) -> Optional[MedicalServiceType]:
        return await get_entity_by_field(self.db, MedicalServiceType, name=medical_service_type_name)
    
    async def list_medical_service_types(self) -> List[MedicalServiceType]:
        return await list_entities(self.db, MedicalServiceType)


    #Medical Service Methods
    async def create_medical_service(self, **medical_service_arguments) -> MedicalService:
        return await create_entity(self.db, MedicalService, **medical_service_arguments)
    
    async def get_medical_service_by_id(self, medical_service_id: int) -> Optional[MedicalService]:
        return await get_entity_by_id(self.db, MedicalService, medical_service_id)
    
    async def list_medical_services_for_medic(self, medic_id: int) -> List[MedicalService]:
        return await list_entities(self.db, MedicalService, filters=[MedicalService.medic_id == medic_id])
    
    async def update_medical_service(self, medical_service_id: int, values: dict) -> None:
        await update_entity_by_id(self.db, MedicalService, medical_service_id, values)

    async def delete_medical_service_by_id(self, medical_service_id: int) -> None:
        await delete_entity_by_id(self.db, MedicalService, medical_service_id)
