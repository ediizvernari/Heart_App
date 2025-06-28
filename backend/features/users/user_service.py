from argon2 import PasswordHasher
from fastapi import HTTPException, status
from backend.config import ENCRYPTED_USER_FIELDS
from backend.core.auth import create_access_token
from backend.core.database.sql_models import User
from backend.features.medics.medic_schemas import MedicOutSchema
from backend.features.medics.medic_service import MedicService
from backend.features.users.user_schemas import (
    UserCreateSchema,
    UserAssignmentStatus,
    UserOutSchema,
)
from backend.core.utils.encryption_utils import encrypt_fields, decrypt_fields
from backend.features.users.user_repository import UserRepository

class UserService:
    def __init__(self, user_repo: UserRepository, medic_service: MedicService):
        self._user_repo = user_repo
        self._medic_service = medic_service

    async def _map_user_to_schema(self, user_record: User) -> UserOutSchema:
        decrypted_fields = decrypt_fields(user_record, ENCRYPTED_USER_FIELDS)
        
        return UserOutSchema(
            id=user_record.id,
            first_name=decrypted_fields["first_name"],
            last_name=decrypted_fields["last_name"],
            email=user_record.email,
        )

    async def create_user(self, user_payload: UserCreateSchema) -> UserOutSchema:
        print(f"[INFO] Creating user account for email={user_payload.email}")
        if await self._user_repo.get_by_email(user_payload.email):
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Email already registered")
        
        ph = PasswordHasher()
        user_hashed_password = ph.hash(user_payload.password)
        
        raw_user_data = user_payload.model_dump()
        
        encrypted_fields = encrypt_fields(raw_user_data, ENCRYPTED_USER_FIELDS)
        
        user_dict = {**encrypted_fields, "email":user_payload.email, "password":user_hashed_password}
        user_record = await self._user_repo.create(**user_dict)
        
        return await self._map_user_to_schema(user_record)


    async def get_user_by_id(self, user_id: int) -> UserOutSchema:
        user_record = await self._user_repo.get_user_by_id(user_id)
        
        if not user_record:
            raise HTTPException(404, "User not found")
        return await self._map_user_to_schema(user_record)

    async def signup_user(self, user_payload: UserCreateSchema) -> str:
        print(f"[INFO] Signing up user email={user_payload.email}")
        
        if await self._user_repo.get_by_email(user_payload.email):
            raise HTTPException(status.HTTP_409_CONFLICT, "Email already registered")
        
        user_schema = await self.create_user(user_payload)
        
        token = create_access_token({"sub":user_schema.id, "role":"user"})
        
        return token

    async def get_user_email_availability(self, email: str) -> dict:
        print(f"[INFO] Checking email availability for {email}")
        
        if await self._user_repo.get_by_email(email):
            raise HTTPException(status.HTTP_409_CONFLICT, "Email already registered")
        print(f"[INFO] Email {email} is available")
        return {"available":True}

    async def assign_user_to_medic(self, user_id: int, medic_id: int) -> UserOutSchema:
        print(f"[INFO] Assigning user {user_id} to medic {medic_id}")
        
        user_record = await self._user_repo.get_user_by_id(user_id)
        if not user_record:
            raise HTTPException(404, "User not found")
        
        medic = await self._medic_service.get_medic_by_id(medic_id)
        if not medic:
            raise HTTPException(404, "Medic not found")
        
        await self._user_repo.assign_medic(user_id, medic_id)
        updated = await self._user_repo.get_user_by_id(user_id)
        
        return await self._map_user_to_schema(updated)

    async def unassign_medic(self, user_id: int) -> UserOutSchema:
        print(f"[INFO] Unassigning medic for user {user_id}")
        user_object = await self._user_repo.get_user_by_id(user_id)
        if not user_object:
            raise HTTPException(404, "User not found")
        
        await self._user_repo.unassign_medic(user_id)
        updated = await self._user_repo.get_user_by_id(user_id)
        
        print (f"[INFO] User {user_id} unassigned from medic, updated user: {updated}")
        return await self._map_user_to_schema(updated)

    async def get_user_assignment_status(self, user_id: int) -> UserAssignmentStatus:
        print(f"[INFO] Checking assignment status for user {user_id}")
        
        user_object = await self._user_repo.get_user_by_id(user_id)
        
        if not user_object:
            raise HTTPException(404, "User not found")
        
        print(f"[INFO] User {user_id} has assigned medic: {user_object.medic_id is not None}")
        return UserAssignmentStatus(has_assigned_medic=user_object.medic_id is not None)

    async def get_assigned_medic(self, user_id: int) -> MedicOutSchema:
        print(f"[INFO] Retrieving assigned medic for user {user_id}")
        
        user_object = await self._user_repo.get_user_by_id(user_id)
        if not user_object:
            raise HTTPException(404, "User not found")
        
        if not user_object.medic_id:
            raise HTTPException(404, "No medic assigned")
        
        print(f"[INFO] User with id {user_id} is assigned to medic with id {user_object.medic_id}")
        return await self._medic_service.get_medic_by_id(user_object.medic_id)