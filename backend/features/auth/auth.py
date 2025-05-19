from fastapi import APIRouter, Depends, status, HTTPException

from backend.features.auth.auth_schemas import TokenSchema, LoginSchema, MessageSchema
from backend.features.auth.deps         import get_auth_service, get_current_account
from backend.features.users.deps        import get_user_service
from backend.features.users.user_schemas import UserCreateSchema, UserOutSchema
from backend.features.medics.deps       import get_medic_service
from backend.features.medics.medic_schemas import MedicCreateSchema
from backend.features.auth.auth_service import AuthService
from backend.features.users.user_service import UserService
from backend.features.medics.medic_service import MedicService

router = APIRouter()

@router.get("/check_email_for_user")
async def check_email(email: str, user_service: UserService = Depends(get_user_service)):
    return await user_service.check_user_email(email)

@router.get("/check_email_for_medic")
async def check_email_for_medic(email: str, medic_service: MedicService = Depends(get_medic_service)):
    return await medic_service.check_medic_email_availability(email=email)

@router.post("/user_signup", response_model=TokenSchema)
async def create_user(user_signup_payload: UserCreateSchema, user_service: UserService = Depends(get_user_service)):
    access_token = await user_service.signup_user(user_payload=user_signup_payload)
    return TokenSchema(access_token=access_token, role="user")

@router.post("/medic_signup", response_model=TokenSchema)
async def create_medic(medic_signup_payload: MedicCreateSchema, medic_service: MedicService = Depends(get_medic_service)):
    access_token = await medic_service.signup_medic(medic_payload=medic_signup_payload)
    return TokenSchema(access_token=access_token, role="medic")

@router.post("/login", response_model=TokenSchema)
async def login_for_access_token(login: LoginSchema, auth_service: AuthService = Depends(get_auth_service)):
    return await auth_service.login_account(login)
