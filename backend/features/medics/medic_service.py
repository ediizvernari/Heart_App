from typing import List, Optional
from fastapi import HTTPException
from argon2 import PasswordHasher

from backend.features.user_health_data.user_health_data_schemas import UserHealthDataOutSchema
from backend.features.user_health_data.user_health_data_service import UserHealthDataService
from backend.utils.encryption_utils import encrypt_data, encrypt_fields, decrypt_data, make_lookup_hash
from backend.core.auth import create_access_token
from backend.features.location.location_service import LocationService
from .medic_repository import MedicRepository
from .medic_schemas import MedicCreateSchema, MedicOutSchema, AssignedUserOutSchema

ph = PasswordHasher()

class MedicService:
    def __init__(self, medic_repo: MedicRepository, location_service: LocationService, user_health_data_service: UserHealthDataService):
        self._medic_repo = medic_repo
        self._location_service = location_service
        self._user_health_data_service = user_health_data_service

    async def signup_medic(self, medic_payload: MedicCreateSchema) -> str:
        if await self._medic_repo.get_medic_by_email(medic_payload.email):
            raise HTTPException(status_code=409, detail="Email already registered")

        country_hash = make_lookup_hash(medic_payload.country)
        encrypted_country = encrypt_data(medic_payload.country)

        country = await self._location_service.repo.get_country_by_lookup_hash(country_hash)
        if country is None:
            country = await self._location_service.repo.create_country(
                name=encrypted_country,
                lookup_hash=country_hash
            )
        country_id = country.id

        city_hash      = make_lookup_hash(medic_payload.city)
        encrypted_city = encrypt_data(medic_payload.city)

        city = await self._location_service.repo.get_city_by_lookup_hash_and_country_id(lookup_hash=city_hash, country_id=country_id)
        if city is None:
            city = await self._location_service.repo.create_city(
                encrypted_city_name=encrypted_city,
                lookup_hash=city_hash,
                country_id=country_id
            )
        city_id = city.id

        hashed_password = ph.hash(medic_payload.password)
        encrypted_personal = encrypt_fields(
            medic_payload,
            fields=["first_name", "last_name", "street_address"]
        )

        medic = await self._medic_repo.create_medic(
            email=medic_payload.email,
            password=hashed_password,
            city_id=city_id,
            **encrypted_personal
        )

        return create_access_token({"sub": medic.id, "role": "medic"})
    
    async def check_medic_email_availability(self, email: str) -> dict:
        existing = await self._medic_repo.get_medic_by_email(email)
        if existing:
            raise HTTPException(status_code=409, detail="Email already registered")
        return {"available": True}
    
    async def get_medic_by_id(self, medic_id: int) -> MedicOutSchema:
        medic = await self._medic_repo.get_medic_by_id(medic_id)
        if not medic:
            raise HTTPException(404, "Medic not found")

        medic_data = {
            "id": medic.id,
            "first_name": decrypt_data(medic.first_name),
            "last_name":  decrypt_data(medic.last_name),
            "email": medic.email,
            "street_address": decrypt_data(medic.street_address),
            "city": await self._location_service.get_city_name_by_id(medic.city_id),
            "country": await self._location_service.get_country_name_by_city_id(medic.city_id),
        }
        return MedicOutSchema.model_validate(medic_data)


    async def filter_medics_by_location(self, city: Optional[str] = None, country: Optional[str] = None) -> List[MedicOutSchema]:
        rows = await self._medic_repo.get_all_medics_with_location()
        filtered_medis: List[MedicOutSchema] = []

        for medic, city_obj, country_obj in rows:
            plain_city    = decrypt_data(city_obj.name)
            plain_country = decrypt_data(country_obj.name)

            if city and not plain_city.lower().startswith(city.lower()):
                continue
            if country and not plain_country.lower().startswith(country.lower()):
                continue

            medic_data = {
                "id":             medic.id,
                "first_name":     decrypt_data(medic.first_name),
                "last_name":      decrypt_data(medic.last_name),
                "email":          medic.email,
                "street_address": decrypt_data(medic.street_address),
                "city":           plain_city,
                "country":        plain_country,
            }
            filtered_medis.append(MedicOutSchema.model_validate(medic_data))

        return filtered_medis
    
    async def get_medics_assigned_users(self, medic_id: int) -> List[AssignedUserOutSchema]:
        assigned_users = await self._medic_repo.get_assigned_users(medic_id)
        return [
            AssignedUserOutSchema.model_validate({
                "id": user.id,
                "first_name": decrypt_data(user.first_name),
                "last_name": decrypt_data(user.last_name),
            })
            for user in assigned_users
        ]

    async def get_assigned_user_health_data(self, medic_id: int, user_id: int) -> UserHealthDataOutSchema:
        assigned_users = await self.get_medics_assigned_users(medic_id)
        if not any(user.id == user_id for user in assigned_users):
            raise HTTPException(403, "Not Authorized")
        return await self._user_health_data_service.get_user_health_data(user_id)