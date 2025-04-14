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

class PredictionResultSchema(BaseModel):
    prediction: float
