from pydantic import BaseModel

class UserCreateSchema(BaseModel):
    first_name: str
    last_name: str
    email: str
    password: str

class UserOutSchema(BaseModel):
    #TODO: Maybe add the shares data with medic field
    first_name: str
    last_name: str
    email: str
    id: int

    model_config = {"from_attributes": True}

class MedicAssignmentRequest(BaseModel):
    medic_id: int

class UserAssignmentStatus(BaseModel):
    has_assigned_medic: bool
    shares_data_with_medic: bool

    model_config = {"from_attributes": True}