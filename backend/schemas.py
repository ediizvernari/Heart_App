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

    class Config:
        orm_mode = True

class UserHealthData(BaseModel):
    birth_date: str
    height: int
    weight: int
    cholesterol_level: int
    ap_hi: int
    ap_lo: int

    class Config:
        orm_mode : True

class Token(BaseModel):
    access_token: str
    token_type: str

class MedicalRecordBase(BaseModel):
    age: int
    ap_hi: int
    ap_lo: int
    cholesterol: int
    BMI: float

    class Config:
        orm_mode = True

class MedicalRecordCreate(MedicalRecordBase):
    pass

class MedicalRecord(MedicalRecordBase):
    id: int
    user_id: int

    class Config:
        orm_mode = True