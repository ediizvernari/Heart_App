from fastapi import APIRouter, Depends, Query
from typing import List
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.connection import get_db
from backend.features.location.location_schemas import CityWithCountrySchema, CountrySchema
from backend.features.location.deps          import get_location_service
from backend.features.location.location_service import LocationService

router = APIRouter()

@router.get("/autocomplete_cities", response_model=List[CityWithCountrySchema])
async def get_autocompleted_cities(query: str = Query(..., min_length=1), location_service: LocationService = Depends(get_location_service)):
    return await location_service.autocomplete_cities(query=query)

@router.get("/countries", response_model=List[CountrySchema])
async def get_all_decrypted_countries(location_service: LocationService = Depends(get_location_service)):
    return await location_service.list_countries()
