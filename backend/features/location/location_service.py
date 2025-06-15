from typing import List
from fastapi import HTTPException

from backend.utils.encryption_utils import encrypt_data, decrypt_data, make_lookup_hash
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
        encrypted_country_name = encrypt_data(payload.name)
        country_lookup_hash = make_lookup_hash(payload.name)

        is_country = await self.repo.get_country_by_lookup_hash(country_lookup_hash)
        if is_country is None:
            country = await self.repo.create_country(encrypted_country_name, country_lookup_hash)

        return CountryOutSchema.model_validate({
            "id": country.id,
            "name": decrypt_data(country.name),
        })

    async def get_all_countries(self) -> List[CountryOutSchema]:
        rows = await self.repo.get_all_countries()
        return [
            CountryOutSchema.model_validate({
                "id": c.id,
                "name": decrypt_data(c.name),
            })
            for c in rows
        ]
    # ─── Cities ─────────────────────────────────────────────────────────────

    async def create_city(self, payload: CityWithCountrySchema) -> CityWithCountryOutSchema:
        country_hash = make_lookup_hash(payload.country)
        encrypted_country_name = encrypt_data(payload.country)

        country_obj = await self.repo.get_country_by_lookup_hash(country_hash)
        if country_obj is None:
            country_obj = await self.repo.create_country(encrypted_country_name, country_hash)
        
        city_hash = make_lookup_hash(payload.city)
        encrypted_city_name = encrypt_data(payload.city)

        city_obj = await self.repo.get_city_by_lookup_hash_and_country_id(city_hash, country_obj.id)
        if city_obj is None:
            city_obj = await self.repo.create_city(encrypted_city_name, city_hash, country_obj.id)

        return CityWithCountryOutSchema.model_validate({
            "id": city_obj.id,
            "city": decrypt_data(city_obj.name),
            "country": await self.get_country_name_by_city_id(city_obj.id),
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
