from pydantic import BaseModel

class PredictionResultSchema(BaseModel):
    prediction: float