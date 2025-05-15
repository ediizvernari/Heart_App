from datetime import datetime
from pydantic import BaseModel

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
    appointment_start: datetime
    appointment_end: datetime
    appointment_status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True
