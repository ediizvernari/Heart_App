from typing import Optional
from pydantic import BaseModel, Field

#Medical Servie Type Schemas
class MedicalServiceTypeSchema(BaseModel):
    name: str

class MedicalServiceTypeOutSchema(BaseModel):
    id: int
    name: str

#Medical Service Schemas
class MedicalServiceSchema(BaseModel):
    name: str
    medical_service_type_id: int
    price: str
    duration_minutes: str

class MedicalServiceOutSchema(BaseModel):
    id: int
    medic_id: int
    medical_service_type_id: int
    name: str
    price: int
    duration_minutes: int

class MedicalServiceUpdateSchema(BaseModel):
    name: Optional[str] = Field(None)
    price: Optional[str] = Field(None)
    duration_minutes: Optional[str] = Field(None)

    class Config:
        orm_mode = True