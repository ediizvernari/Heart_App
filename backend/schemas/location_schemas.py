from pydantic import BaseModel

class CitySchema(BaseModel):
    name: str
    country: str

class CountrySchema(BaseModel):
    name: str

class LocationSchema(BaseModel):
    city: CitySchema
    country: CountrySchema
    