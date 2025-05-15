from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

class MedicAvailabilityCreateSchema(BaseModel):
    weekday: int = Field(..., ge=0, le=6, description="0=Monday ... 6=Sunday") #ge and le are names from the pydantic standard
    start_time: str
    end_time: str

class MedicAvailabilityUpdateSchema(BaseModel):
    weekday: Optional[int] = Field(None, ge=0, le=6)
    start_time: Optional[str]
    end_time: Optional[str]

class MedicAvailabilityOutSchema(BaseModel):
    id: int
    medic_id: int
    weekday: int
    start_time: str
    end_time: str
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True