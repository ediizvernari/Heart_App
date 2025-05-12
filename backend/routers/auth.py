from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from backend.schemas import user_schemas, medic_schemas, token_schema
from backend.database.connection import get_db
from backend.database.sql_models import User
from backend.services.user_service import signup_user, check_user_email_availability
from backend.services.medic import signup_medic, check_medic_email_availability
from backend.services.account_service import login_account, get_current_account

router = APIRouter()

@router.get("/check_email_for_user")
async def check_email(email: str, db: AsyncSession = Depends(get_db)):
    return await check_user_email_availability(db=db, email=email)

@router.get("/check_email_for_medic")
async def check_email_for_medic(email: str, db: AsyncSession = Depends(get_db)):
    return await check_medic_email_availability(db=db, email=email)

@router.post("/user_signup", response_model=token_schema.Token)
async def create_user(user: user_schemas.UserCreateSchema, db: AsyncSession = Depends(get_db)):
    access_token = await signup_user(db=db, user=user)
    return token_schema.Token(access_token=access_token, token_type="bearer")

@router.post("/medic_signup", response_model=token_schema.Token)
async def create_medic(medic: medic_schemas.MedicCreate, db: AsyncSession = Depends(get_db)):
    access_token = await signup_medic(db=db, medic=medic)
    return token_schema.Token(access_token=access_token, token_type="bearer")

@router.post("/login", response_model=token_schema.Token)
async def login_for_access_token(login: user_schemas.Login, db: AsyncSession = Depends(get_db)):
    result = await login_account(email=login.email, password=login.password, db=db)
    return token_schema.Token(**result)

@router.get("/me", response_model=user_schemas.UserSchema, description="Get the current logged-in user")
async def read_user_me(current_user: User = Depends(get_current_account)):
    if not isinstance(current_user, User):
        raise HTTPException(status_code=403, detail="Not a user")
    return current_user
