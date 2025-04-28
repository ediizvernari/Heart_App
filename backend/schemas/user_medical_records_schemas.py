from datetime import datetime
from pydantic import BaseModel

class UserMedicalRecordSchema(BaseModel):
    user_id: int
    cvd_risk: str
    birth_date: str
    height: str
    weight: str
    cholesterol_level: str
    ap_hi: str
    ap_lo: str

class UserMedicalRecordOutSchema(UserMedicalRecordSchema):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True
    