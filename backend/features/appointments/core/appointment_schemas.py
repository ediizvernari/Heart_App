from datetime import datetime
from pydantic import BaseModel

from backend.features.medics.medic_schemas import MedicOutSchema
from backend.features.users.user_schemas import UserOutSchema

class AppointmentCreateSchema(BaseModel):
    medical_service_id: int
    medic_id: int
    address: str
    appointment_start: datetime
    appointment_end: datetime


class AppointmentOutSchema(BaseModel):
    id: int
    user_id: int
    medic_id: int

    medical_service_id: int
    address: str
    medical_service_name: str
    medical_service_price: int
    appointment_start: datetime
    appointment_end: datetime
    appointment_status: str
    created_at: datetime
    updated_at: datetime

    patient: UserOutSchema
    medic: MedicOutSchema

    model_config = {"from_attributes": True}
