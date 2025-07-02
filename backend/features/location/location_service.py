import logging
from typing import List
from fastapi import HTTPException
from backend.core.database.sql_models import City, Country
from backend.core.utils.encryption_utils import decrypt_data, encrypt_data, encrypt_fields, decrypt_fields, make_lookup_hash
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
        logging.debug(f"Creating country with name={payload.name}")

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
        logging.debug("Fetching all countries")

        country_records=await self.repo.get_all_countries()
        
        result_list:List[CountryOutSchema]=[]
        
        for country_record in country_records:
            name_decrypted=decrypt_data(country_record.name)
            result_list.append(CountryOutSchema.model_validate({"id":country_record.id,"name":name_decrypted}))
        
        return result_list

    # ─── Cities ─────────────────────────────────────────────────────────────

    async def create_city(self, payload: CityWithCountrySchema) -> CityWithCountryOutSchema:
        logging.debug(f"Creating city={payload.city} under country={payload.country}")

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
        logging.debug(f"Fetching city name for city_id={city_id}")

        city_obj=await self.repo.get_city_by_id(city_id)
        
        if city_obj is None:
            raise HTTPException(404,"City not found")
        
        return decrypt_data(city_obj.name)

    async def get_country_name_by_city_id(self, city_id: int) -> str:
        logging.debug(f"Fetching country name for city_id={city_id}")

        city_obj=await self.repo.get_city_by_id(city_id)
        if city_obj is None:
            raise HTTPException(404,"City not found")

        country_obj=await self.repo.get_country_by_id(city_obj.country_id)
        if country_obj is None:
            raise HTTPException(404,"Country not found")

        return decrypt_data(country_obj.name)
