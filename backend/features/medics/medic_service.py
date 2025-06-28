from typing import List, Optional
from fastapi import HTTPException
from argon2 import PasswordHasher

from backend.config import ENCRYPTED_MEDIC_FIELDS
from backend.core.utils.encryption_utils import encrypt_data, encrypt_fields, decrypt_data, make_lookup_hash
from backend.core.auth import create_access_token
from backend.features.location.location_service import LocationService

from .medic_repository import MedicRepository
from .medic_registry_repository import MedicRegistryRepository
from .medic_schemas import MedicCreateSchema, MedicOutSchema, AssignedUserOutSchema

ph = PasswordHasher()

class MedicService:
    def __init__(self, medic_repo: MedicRepository, location_service: LocationService, medic_registry_repo: MedicRegistryRepository):
        self._medic_repo = medic_repo
        self._location_service = location_service
        self._medic_registry_repo = medic_registry_repo

    async def signup_medic(self, medic_payload: MedicCreateSchema) -> str:
        print(f"[INFO] Signing up medic email={medic_payload.email}")
        
        if await self._medic_repo.get_medic_by_email(medic_payload.email):
            raise HTTPException(status_code=409, detail="Email already registered")

        country_lookup = make_lookup_hash(medic_payload.country)
        print(f"[DEBUG] country_lookup={country_lookup}")
        
        encrypted_country = encrypt_data(medic_payload.country)

        country_obj = await self._location_service.repo.get_country_by_lookup_hash(country_lookup)
        if country_obj is None:
            country_obj = await self._location_service.repo.create_country(encrypted_country, country_lookup)
        country_id = country_obj.id

        city_lookup = make_lookup_hash(medic_payload.city)
        print(f"[DEBUG] city_lookup={city_lookup}")
        encrypted_city = encrypt_data(medic_payload.city)

        city_obj = await self._location_service.repo.get_city_by_lookup_hash_and_country_id(city_lookup, country_id)
        if city_obj is None:
            city_obj = await self._location_service.repo.create_city(encrypted_city, city_lookup, country_id)
        city_id = city_obj.id

        registry_lookup = make_lookup_hash(medic_payload.license_number)
        print(f"[DEBUG] registry_lookup={registry_lookup}")
        registry_entry = await self._medic_registry_repo.get_registry_medic_by_lookup_hash(registry_lookup)
        
        if registry_entry is None:
            raise HTTPException(400, "License number not found in registry")

        hashed_password = ph.hash(medic_payload.password)
        
        encrypted_personal = encrypt_fields(medic_payload.model_dump(), ENCRYPTED_MEDIC_FIELDS)

        medic_record = await self._medic_repo.create_medic(
            email=medic_payload.email,
            password=hashed_password,
            city_id=city_id,
            registry_id=registry_entry.id,
            **encrypted_personal
        )

        return create_access_token({"sub": medic_record.id, "role": "medic"})

    async def check_medic_email_availability(self, email: str) -> dict:
        print(f"[INFO] Checking medic email availability for email={email}")
        existing = await self._medic_repo.get_medic_by_email(email)
        if existing:
            raise HTTPException(status_code=409, detail="Email already registered")
        return {"available": True}

    async def get_medic_by_id(self, medic_id: int) -> MedicOutSchema:
        print(f"[INFO] Retrieving medic by id={medic_id}")
        medic = await self._medic_repo.get_medic_by_id(medic_id)
        if medic is None:
            raise HTTPException(404, "Medic not found")

        return MedicOutSchema.model_validate({
            "id": medic.id,
            "first_name": decrypt_data(medic.first_name),
            "last_name": decrypt_data(medic.last_name),
            "email": medic.email,
            "street_address": decrypt_data(medic.street_address),
            "city": await self._location_service.get_city_name_by_id(medic.city_id),
            "country": await self._location_service.get_country_name_by_city_id(medic.city_id),
        })

    async def filter_medics_by_location(self, city: Optional[str]=None, country: Optional[str]=None) -> List[MedicOutSchema]:
        print(f"[INFO] Filtering medics by city={city}, country={country}")
        rows = await self._medic_repo.get_all_medics_with_location()
        filtered: List[MedicOutSchema] = []

        for medic, city_obj, country_obj in rows:
            plain_city    = decrypt_data(city_obj.name)
            plain_country = decrypt_data(country_obj.name)

            if city and not plain_city.lower().startswith(city.lower()):
                continue
            if country and not plain_country.lower().startswith(country.lower()):
                continue

            filtered.append(
                MedicOutSchema.model_validate({
                    "id": medic.id,
                    "first_name": decrypt_data(medic.first_name),
                    "last_name": decrypt_data(medic.last_name),
                    "email": medic.email,
                    "street_address": decrypt_data(medic.street_address),
                    "city": plain_city,
                    "country": plain_country
                })
            )
        return filtered

    async def get_medics_assigned_users(self, medic_id: int) -> List[AssignedUserOutSchema]:
        print(f"[INFO] Fetching assigned users for medic_id={medic_id}")
        assigned = await self._medic_repo.get_assigned_users(medic_id)
        
        return [
            AssignedUserOutSchema.model_validate({
                "id": user.id,
                "first_name": decrypt_data(user.first_name),
                "last_name": decrypt_data(user.last_name)
            })
            for user in assigned
        ]