from pydantic import BaseModel

class Login(BaseModel):
    email: str
    password: str

#Clasa asta mosteneste clasa UserBase si are in plus un password
class UserCreate(BaseModel):
    first_name: str
    last_name: str
    email: str
    password: str

#TODO: Add the rest of the fields at the data insertion later
class User(UserCreate):
    id: int

    model_config = {
        "from_attributes": True
    }

class UserHealthData(BaseModel):
    birth_date: str
    height: int
    weight: int
    cholesterol_level: int
    ap_hi: int
    ap_lo: int

    model_config = {
    "from_attributes": True
    }

class Token(BaseModel):
    access_token: str
    token_type: str

class MedicalRecordBase(BaseModel):
    age: int
    ap_hi: int
    ap_lo: int
    cholesterol: int
    BMI: float

    model_config = {
        "from_attributes": True
    }

class PredictionResult(BaseModel):
    prediction: float

class MedicalRecordCreate(MedicalRecordBase):
    pass

class MedicalRecord(MedicalRecordBase):
    id: int
    user_id: int

    model_config = {
        "from_attributes": True
    }