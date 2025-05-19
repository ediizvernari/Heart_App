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

    model_config = {"from_attributes": True}

class UserMedicalRecordOutSchema(UserMedicalRecordSchema):
    id: int
    created_at: datetime

    model_config = {"from_attributes": True}
    