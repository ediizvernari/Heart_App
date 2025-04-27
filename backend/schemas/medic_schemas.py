from pydantic import BaseModel

class MedicCreate(BaseModel):
    first_name: str
    last_name: str
    email: str
    password: str
    street_address: str
    city: str
    country:str


class MedicOut(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
    street_address: str
    city: str
    country: str

    class Config:
        from_attributes = True