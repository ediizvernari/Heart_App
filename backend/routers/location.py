from fastapi import APIRouter, Depends, Query
from typing import List
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.connection import get_db
from backend.schemas.location_schemas import CityWithCountrySchema, CountrySchema
from backend.services.location_service import autocomplete_cities, get_decrypted_countries

router = APIRouter()

@router.get("/autocomplete_cities", response_model=List[CityWithCountrySchema])
async def get_autocompleted_cities(
    query: str = Query(..., min_length=1),
    db: AsyncSession = Depends(get_db)
):
    return await autocomplete_cities(db=db, query=query)

@router.get("/countries", response_model=List[CountrySchema])
async def get_all_decrypted_countries(
    db: AsyncSession = Depends(get_db)
):
    return await get_decrypted_countries(db=db)
