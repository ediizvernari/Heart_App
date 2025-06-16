from typing import List
from fastapi import HTTPException
from backend.database.sql_models import City, Country
from backend.utils.encryption_utils import decrypt_data, encrypt_data, encrypt_fields, decrypt_fields, make_lookup_hash
from backend.features.location.location_repository import LocationRepository
from .location_schemas import (
    CountrySchema,
    CountryOutSchema,
    CityWithCountrySchema,
    CityWithCountryOutSchema,
)

class LocationService:
    def __init__(self, repo: LocationRepository):
        self.repo=repo

    # ─── Countries ──────────────────────────────────────────────────────────

    async def create_country(self, payload: CountrySchema) -> CountryOutSchema:
        print(f"[INFO] Creating country with name={payload.name}")

        encrypted_country_name = encrypt_data(payload.name)
        country_lookup_hash = make_lookup_hash(payload.name)

        existing_country = await self.repo.get_country_by_lookup_hash(country_lookup_hash)
        if existing_country is None:
            country_record = await self.repo.create_country(encrypted_country_name, country_lookup_hash)
        else:
            country_record = existing_country

        decrypted_name=decrypt_data(country_record.name)

        return CountryOutSchema.model_validate({
            "id":country_record.id,
            "name":decrypted_name
        })

    async def get_all_countries(self) -> List[CountryOutSchema]:
        print("[INFO] Fetching all countries")

        country_records=await self.repo.get_all_countries()
        
        result_list:List[CountryOutSchema]=[]
        
        for country_record in country_records:
            name_decrypted=decrypt_data(country_record.name)
            result_list.append(CountryOutSchema.model_validate({"id":country_record.id,"name":name_decrypted}))
        
        return result_list

    # ─── Cities ─────────────────────────────────────────────────────────────

    async def create_city(self, payload: CityWithCountrySchema) -> CityWithCountryOutSchema:
        print(f"[INFO] Creating city={payload.city} under country={payload.country}")

        country_hash = make_lookup_hash(payload.country)
        encrypted_country_name = encrypt_data(payload.country)

        country_obj = await self.repo.get_country_by_lookup_hash(country_hash)
        if country_obj is None:
            country_obj = await self.repo.create_country(encrypted_country_name, country_hash)

        city_hash = make_lookup_hash(payload.city)
        encrypted_city_name = encrypt_data(payload.city)

        city_obj = await self.repo.get_city_by_lookup_hash_and_country_id(city_hash, country_obj.id)
        if city_obj is None:
            city_obj = await self.repo.create_city(encrypted_city_name, city_hash,country_obj.id)

        city_name_decrypted = decrypt_data(city_obj.name)
        country_name_decrypted = await self.get_country_name_by_city_id(city_obj.id)

        return CityWithCountryOutSchema.model_validate({
            "id": city_obj.id,
            "city": city_name_decrypted,
            "country": country_name_decrypted
        })

    async def get_city_name_by_id(self, city_id: int) -> str:
        print(f"[INFO] Fetching city name for city_id={city_id}")

        city_obj=await self.repo.get_city_by_id(city_id)
        
        if city_obj is None:
            raise HTTPException(404,"City not found")
        
        return decrypt_data(city_obj.name)

    async def get_country_name_by_city_id(self, city_id: int) -> str:
        print(f"[INFO] Fetching country name for city_id={city_id}")

        city_obj=await self.repo.get_city_by_id(city_id)
        if city_obj is None:
            raise HTTPException(404,"City not found")

        country_obj=await self.repo.get_country_by_id(city_obj.country_id)
        if country_obj is None:
            raise HTTPException(404,"Country not found")

        return decrypt_data(country_obj.name)

    async def autocomplete_cities(self, query: str) -> List[CityWithCountryOutSchema]:
        print(f"[INFO] Autocompleting cities for query={query}")

        q=query.lower()
        rows=await self.repo.get_all_cities_with_countries()
        
        suggestions:List[CityWithCountryOutSchema]=[]
        
        for city_obj,country_obj in rows:
            city_name=decrypt_data(city_obj.name)
            country_name=decrypt_data(country_obj.name)
            
            if city_name.lower().startswith(q):
                suggestions.append(
                    CityWithCountryOutSchema.model_validate({
                        "id":city_obj.id,
                        "city":city_name,
                        "country":country_name
                    })
                )
        
        return suggestions

    # ─── Helpers ────────────────────────────────────────────────────────────

    @staticmethod
    def matches_location(city_obj: City, country_obj: Country, filtered_city_name: str | None = None, filtered_country_name: str | None = None) -> bool:
        city = decrypt_data(city_obj.name).lower()
        country = decrypt_data(country_obj.name).lower()
        if filtered_city_name and not city.startswith(filtered_city_name.lower()):
            return False
        
        if filtered_country_name and not country.startswith(filtered_country_name.lower()):
            return False
        
        return True