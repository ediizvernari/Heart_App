from pydantic import BaseModel

class MedicalRecordBase(BaseModel):
    age: int
    ap_hi: int
    ap_lo: int
    cholesterol: int
    BMI: float

    model_config = {
        "from_attributes": True
    }

class MedicalRecordCreate(MedicalRecordBase):
    user_id: int
    pass

class MedicalRecord(MedicalRecordBase):
    id: int
    user_id: int

    model_config = {
        "from_attributes": True
    }
    