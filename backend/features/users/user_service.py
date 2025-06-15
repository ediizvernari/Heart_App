from argon2 import PasswordHasher
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException, status


from backend.features.medics.medic_schemas import MedicOutSchema
from backend.features.medics.medic_service import MedicService
from backend.utils.encryption_utils import decrypt_fields, encrypt_fields
from backend.core.auth import create_access_token
from backend.features.users.user_repository import UserRepository
from backend.features.users.user_schemas import UserCreateSchema, UserAssignmentStatus, UserOutSchema
from backend.features.medics.medic_repository import MedicRepository

class UserService:
    def __init__(self, user_repo: UserRepository, medic_repo: MedicRepository, medic_service: MedicService):
        self._user_repo = user_repo
        self._medic_repo = medic_repo
        self._medic_service = medic_service

    async def _get_user_by_id(self, user_id: int) -> UserOutSchema:
        encrypted_user = await self._user_repo.get_user_by_id(user_id)

        if not encrypted_user:
            raise HTTPException(404, "User not found")

        decrypted_user_data = decrypt_fields(encrypted_user, ["first_name", "last_name"])

        return UserOutSchema(
            first_name=decrypted_user_data["first_name"],
            last_name=decrypted_user_data["last_name"],
            email=encrypted_user.email,
            id=encrypted_user.id,
        )

    async def create_user(self, user_payload: UserCreateSchema) -> UserOutSchema:
        ph = PasswordHasher()
        
        if await self._user_repo.get_by_email(user_payload.email):
            raise HTTPException(400, "Email already registered")
        
        user_hashed_password = ph.hash(user_payload.password)
        encrypted_fields = encrypt_fields(user_payload, ["first_name", "last_name"])

        user_dict = {
            **encrypted_fields,
            "email": user_payload.email,
            "password": user_hashed_password,
        }

        user = await self._user_repo.create(**user_dict)
        
        return await self._get_user_by_id(user.id)

    async def signup_user(self, user_payload: UserCreateSchema) -> str:
        if not self.check_user_email(user_payload.email):
            raise HTTPException(409, "Email already registered")
        user = await self.create_user(user_payload)
        token = create_access_token({"sub": user.id, "role": "user"})
        return token

    async def check_user_email(self, email: str) -> dict:
        if await self._user_repo.get_by_email(email):
            raise HTTPException(409, "Email already registered")
        return {"available": True}

    async def assign_user_to_medic(self, user_id: int, medic_id: int) -> UserOutSchema:
        user = await self._user_repo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(404, "User not found")
        medic = await self._medic_repo.get_medic_by_id(medic_id)
        if not medic:
            raise HTTPException(404, "Medic not found")
        user.medic_id = medic_id
        await self._user_repo.db.commit()
        await self._user_repo.db.refresh(user)

        return await self._get_user_by_id(user.id)

    async def unassign_medic(self, user_id: int) -> UserOutSchema:
        user = await self._user_repo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(404, "User not found")
        user.medic_id = None
        await self._user_repo.db.commit()
        await self._user_repo.db.refresh(user)

        return await self._get_user_by_id(user.id)
    
    async def get_user_assignment_status(self, user_id: int) -> UserAssignmentStatus:
        user = await self._user_repo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(404, "User not found")
        return UserAssignmentStatus(
            has_assigned_medic=user.medic_id is not None,
        )

    async def get_assigned_medic(self, user_id: int) -> MedicOutSchema:
        user_object = await self._user_repo.get_user_by_id(user_id)
        if not user_object:
            raise HTTPException(404, "User not found")
        
        if not user_object.medic_id:
            raise HTTPException(404, "No medic assigned")
        
        return await self._medic_service.get_medic_by_id(user_object.medic_id)
