from pydantic import BaseModel

class CityWithCountrySchema(BaseModel):
    city: str
    country: str

class CountrySchema(BaseModel):
    name: str

#TODO: See if these are needed
class CountryOutSchema(BaseModel):
    id: int
    name: str

    model_config = {"from_attributes": True}

class CityWithCountryOutSchema(BaseModel):
    id: int
    name: str
    country_id: int

    model_config = {"from_attributes": True}