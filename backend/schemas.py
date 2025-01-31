#TODO: Check if all these classes are needed or I can use only one class for each model
from pydantic import BaseModel

#User base class which stores the mandatory fields before taking the test
class UserBase(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str

#Clasa asta mosteneste clasa UserBase si are in plus un password
class UserCreate(UserBase):
    password: str

class User(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
    password: str
    is_admin: bool

    class Config:
        from_attributes = True

class MedicalRecordsBase(BaseModel):
    male: int
    age: int
    education: int
    currentSmoker: int
    cigsPerDay: int
    BPMeds: int
    prevalentStroke: int
    prevalentHyp: int
    diabetes: int
    totChol: int
    sysBP: float
    diaBP: float
    BMI: float
    heartRate: int
    glucose: int
    TenYearCHD: int

class MedicalRecordsCreate(MedicalRecordsBase):
    pass

class MedicalRecord(MedicalRecordsBase):
    id: int
    user_id: int

    class Config:
        orm_mode = True