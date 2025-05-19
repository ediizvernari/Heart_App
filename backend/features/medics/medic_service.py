from typing import List, Optional
from fastapi import HTTPException
from argon2 import PasswordHasher

from backend.features.user_health_data.user_health_data_schemas import UserHealthDataOutSchema
from backend.features.user_health_data.user_health_data_service import UserHealthDataService
from backend.utils.encryption_utils import encrypt_data, encrypt_fields, decrypt_data
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
            raise HTTPException(400, "Email already registered")

        encrypted_country = encrypt_data(medic_payload.country)
        encrypted_city    = encrypt_data(medic_payload.city)

        country = await self._location_service.repo.get_country_by_name(encrypted_country)
        if not country:
            country = await self._location_service.repo.create_country(encrypted_country)
        country_id = country.id

        city = await self._location_service.repo.get_city_by_name_and_country(
            city_name=encrypted_city,
            country_id=country_id
        )
        if not city:
            city = await self._location_service.repo.create_city(encrypted_city, country_id)
        city_id = city.id

        hashed = ph.hash(medic_payload.password)
        encrypted = encrypt_fields(medic_payload, ["first_name", "last_name", "street_address"])

        medic = await self._medic_repo.create_medic(
            **encrypted,
            email=medic_payload.email,
            password=hashed,
            city_id=city_id,
        )

        return create_access_token({"sub": medic.id, "role": "medic"})
    
    async def check_medic_email_availability(self, email: str) -> dict:
        existing = await self._medic_repo.get_medic_by_email(email)
        if existing:
            raise HTTPException(status_code=400, detail="Email already registered")
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
                "shares_data_with_medic": user.share_data_with_medic,
            })
            for user in assigned_users
        ]

    async def get_assigned_user_health_data(self, medic_id: int, user_id: int) -> UserHealthDataOutSchema:
        assigned_users = await self.get_medics_assigned_users(medic_id)
        if not any(user.id == user_id for user in assigned_users):
            raise HTTPException(403, "Not Authorized")
        return await self._user_health_data_service.get_user_health_data(user_id)