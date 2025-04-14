from pydantic import BaseModel

class MedicCreate(BaseModel):
    first_name: str
    last_name: str
    email: str
    password: str
    street_address: str
    city: str
    postal_code: str
    country:str
    