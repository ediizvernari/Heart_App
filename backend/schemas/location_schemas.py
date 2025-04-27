from pydantic import BaseModel

class CityWithCountrySchema(BaseModel):
    city: str
    country: str

class CountrySchema(BaseModel):
    name: str
    