from pydantic import BaseModel

class UserHealthDataSchema(BaseModel):
    birth_date: str
    height: int
    weight: int
    cholesterol_level: int
    ap_hi: int
    ap_lo: int

    model_config = {
    "from_attributes": True
    }

class UserHealthDataOutSchema(BaseModel):
    date_of_birth: str
    height_cm: str
    weight_kg: str
    cholesterol_level: str
    systolic_blood_pressure: str
    diastolic_blood_pressure: str

class PredictionResultSchema(BaseModel):
    prediction: float
