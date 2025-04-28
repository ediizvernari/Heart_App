from pydantic import BaseModel

class Login(BaseModel):
    email: str
    password: str

#Clasa asta mosteneste clasa UserBase si are in plus un password
class UserCreateSchema(BaseModel):
    first_name: str
    last_name: str
    email: str
    password: str

class UserSchema(UserCreateSchema):
    id: int

    model_config = {
        "from_attributes": True
    }
    
class MedicAssignmentRequest(BaseModel):
    medic_id: int

class UserAssignmentStatus(BaseModel):
    has_assigned_medic: bool
    shares_data_with_medic: bool

class PatientOut(BaseModel):
    id: int
    first_name: str
    last_name: str
    shares_data_with_medic: bool

    class Config:
        from_attributes = True