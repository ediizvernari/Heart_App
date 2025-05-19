from typing import List
from fastapi import HTTPException

from backend.utils.encryption_utils import encrypt_data, decrypt_data
from .location_repository import LocationRepository
from .location_schemas import (
    CountrySchema,
    CountryOutSchema,
    CityWithCountrySchema,
    CityWithCountryOutSchema,
)

class LocationService:
    def __init__(self, repo: LocationRepository):
        self.repo = repo

    # ─── Countries ──────────────────────────────────────────────────────────

    async def create_country(self, payload: CountrySchema) -> CountryOutSchema:
        encrypted = encrypt_data(payload.name)
        country = await self.repo.create_country(encrypted)
        return CountryOutSchema.model_validate({
            "id": country.id,
            "name": decrypt_data(country.name),
        })

    async def list_countries(self) -> List[CountryOutSchema]:
        rows = await self.repo.get_all_countries()
        return [
            CountryOutSchema.model_validate({
                "id": c.id,
                "name": decrypt_data(c.name),
            })
            for c in rows
        ]

    async def get_country_name_by_id(self, country_id: int) -> str:
        country = await self.repo.get_country_by_id(country_id)
        if not country:
            raise HTTPException(404, "Country not found")
        return decrypt_data(country.name)

    # ─── Cities ─────────────────────────────────────────────────────────────

    async def create_city(self, payload: CityWithCountrySchema) -> CityWithCountryOutSchema:
        encrypted_country = encrypt_data(payload.country)
        country = await self.repo.get_country_by_name(encrypted_country)
        if not country:
            country = await self.repo.create_country(encrypted_country)

        encrypted_city = encrypt_data(payload.city)
        city = await self.repo.create_city(encrypted_city, country.id)

        return CityWithCountryOutSchema.model_validate({
            "id": city.id,
            "city": decrypt_data(city.name),
            "country": await self.get_country_name_by_city_id(city.id),
        })

    async def get_city_name_by_id(self, city_id: int) -> str:
        city = await self.repo.get_city_by_id(city_id)
        if not city:
            raise HTTPException(404, "City not found")
        return decrypt_data(city.name)

    async def get_country_name_by_city_id(self, city_id: int) -> str:
        city = await self.repo.get_city_by_id(city_id)
        if not city:
            raise HTTPException(404, "City not found")
        country = await self.repo.get_country_by_id(city.country_id)
        if not country:
            raise HTTPException(404, "Country not found")
        return decrypt_data(country.name)

    async def autocomplete_cities(self, query: str) -> List[CityWithCountryOutSchema]:
        q = query.lower()
        rows = await self.repo.get_all_cities_with_countries()
        results: List[CityWithCountryOutSchema] = []
        for city_obj, country_obj in rows:
            name = decrypt_data(city_obj.name)
            if q in name.lower():
                results.append(CityWithCountryOutSchema.model_validate({
                    "id": city_obj.id,
                    "city": name,
                    "country": decrypt_data(country_obj.name),
                }))
        return results

    # ─── Helpers ────────────────────────────────────────────────────────────

    @staticmethod
    def matches_location(
        city_obj, country_obj,
        filtered_city_name: str | None = None,
        filtered_country_name: str | None = None
    ) -> bool:
        city = decrypt_data(city_obj.name).lower()
        country = decrypt_data(country_obj.name).lower()
        if filtered_city_name and not city.startswith(filtered_city_name.lower()):
            return False
        if filtered_country_name and not country.startswith(filtered_country_name.lower()):
            return False
        return True
