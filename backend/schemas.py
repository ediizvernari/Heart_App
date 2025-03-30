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

class UserPersonalData(BaseModel):
    birth_date: str
    height: int
    weight: int
    is_male: int
    education: int
    current_smoker: int
    cigs_per_day: int
    BPMeds: int
    prevalentStroke: int
    prevalentHyp: int
    diabetes: int
    totChol: int
    glucose: int

    class Config:
        orm_mode : True

class Token(BaseModel):
    access_token: str
    token_type: str

class MedicalRecordsBase(BaseModel):
    male: int
    age: int
    education: int
    currentSmoker: int
    cigsPerDay: int
    BPMeds: int #Blood pressure medication
    prevalentStroke: int #Stroke prevalent in family history
    prevalentHyp: int #Hypertension prevalent in family history
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