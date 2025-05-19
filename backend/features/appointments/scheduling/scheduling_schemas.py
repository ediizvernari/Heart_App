from pydantic import BaseModel

class TimeSlotSchema(BaseModel):
    start: str # HH:MM
    end: str   # HH:MM