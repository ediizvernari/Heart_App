from fastapi import APIRouter, Depends, Query
from typing import List

from backend.features.auth.deps import get_current_account
from backend.features.location.location_schemas import CityWithCountrySchema, CountrySchema
from backend.features.location.deps import get_location_service
from backend.features.location.location_service import LocationService

router = APIRouter(dependencies=[Depends(get_location_service), Depends(get_current_account)])

@router.get("/autocomplete_cities", response_model=List[CityWithCountrySchema])
async def get_autocompleted_cities(query: str = Query(..., min_length=1), location_service: LocationService = Depends(get_location_service)):
    return await location_service.autocomplete_cities(query=query)
