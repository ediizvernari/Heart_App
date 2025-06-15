from pydantic import BaseModel

class MedicCreateSchema(BaseModel):
    first_name: str
    last_name: str
    email: str
    password: str
    street_address: str
    city: str
    country:str


class MedicOutSchema(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
    street_address: str
    city: str
    country: str

    model_config = {"from_attributes": True}

class AssignedUserOutSchema(BaseModel):
    id: int
    first_name: str
    last_name: str

    model_config = {"from_attributes": True}