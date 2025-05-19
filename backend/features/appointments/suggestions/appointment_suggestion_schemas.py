from datetime import datetime
from pydantic import BaseModel

#TODO: Maybe put the status here
class AppointmentSuggestionCreateSchema(BaseModel):
    medical_service_id: int
    reason: str

class AppointmentSuggestionOutSchema(BaseModel):
    id: int
    user_id: int
    medic_id: int
    medical_service_id: int
    status: str
    reason: str
    created_at: datetime

    class Config:
        orm_mode = True