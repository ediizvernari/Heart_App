from pydantic import BaseModel

class UserHealthDataSchema(BaseModel):
    birth_date: str
    height: int
    weight: int
    cholesterol_level: int
    ap_hi: int
    ap_lo: int

class UserHealthDataOutSchema(BaseModel):
    date_of_birth: str
    height_cm: int
    weight_kg: int
    cholesterol_level: int
    systolic_blood_pressure: int
    diastolic_blood_pressure: int

    model_config = {"from_attributes": True}
