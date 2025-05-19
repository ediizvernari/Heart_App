from fastapi import HTTPException

from backend.features.auth.auth_schemas import LoginSchema, TokenSchema
from ..users.user_repository import UserRepository
from ..medics.medic_repository import MedicRepository
from ...core.auth import create_access_token, verify_password


class AuthService:
    def __init__(self, user_repo: UserRepository, medic_repo: MedicRepository):
        self._user_repo = user_repo
        self._medic_repo = medic_repo


    async def login_account(self, payload: LoginSchema) -> TokenSchema:
        found_user = await self._user_repo.get_by_email(payload.email)
        if found_user and verify_password(payload.password, found_user.password):
            token = create_access_token(data={"sub": found_user.id, "role": "user"})
            return TokenSchema(access_token=token, role="user")
        
        found_medic = await self._medic_repo.get_medic_by_email(payload.email)
        if found_medic and verify_password(payload.password, found_medic.password):
            token = create_access_token(data={"sub": found_medic.id, "role": "medic"})
            return TokenSchema(access_token=token, role="medic")
        
        raise HTTPException(
            status_code=400,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    