from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from backend.sql_models import User
from .. import crud, schemas
from ..auth import create_access_token, verify_password, get_current_account
from ..database import get_db

router = APIRouter()

@router.post("/", response_model=schemas.Token)
async def create_user(user: schemas.UserCreate, db: AsyncSession = Depends(get_db)):
    db_user = await crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    user = await crud.create_user(db=db, user=user)
    access_token = create_access_token(data={"sub": user.id, "role": "user"})
    return schemas.Token(access_token=access_token, token_type="bearer")

@router.post("/signup_for_medic", response_model=schemas.Token)
async def create_medic(medic: schemas.MedicCreate, db: AsyncSession = Depends(get_db)):
    db_medic = await crud.get_medic_by_email(db, email=medic.email)
    if db_medic:
        raise HTTPException(status_code=400, detail="Username already registered")
    medic = await crud.create_medic(db=db, medic=medic)
    access_token = create_access_token(data={"sub": medic.id, "role": "medic"})
    return schemas.Token(access_token=access_token, token_type="bearer")


#In functia de loginm verificam daca userul e user sau medic, in functie de asta ii dam tokenul corespunzator
@router.post("/login", response_model=schemas.Token)
async def login_for_access_token(login: schemas.Login, db: AsyncSession = Depends(get_db)):
    user = await crud.get_user_by_email(db, email=login.email)
    if user and verify_password(login.password, user.password):
        access_token = create_access_token(data={"sub": user.id, "role": "user"})
        return schemas.Token(access_token=access_token, token_type="bearer", role="user")

    medic = await crud.get_medic_by_email(db, email=login.email)
    if medic and verify_password(login.password, medic.password):
        access_token = create_access_token(data={"sub": medic.id, "role": "medic"})
        return schemas.Token(access_token=access_token, token_type="bearer", role="medic")

    raise HTTPException(
        status_code=400,
        detail="Incorrect email or password",
        headers={"WWW-Authenticate": "Bearer"},
    )


@router.get("/me", response_model=schemas.User, description="Get the current logged-in user")
async def read_user_me(current_user: User = Depends(get_current_account)):
    if not isinstance(current_user, User):
        raise HTTPException(status_code=403, detail="Not a user")
    return current_user

@router.get("/users", response_model=List[schemas.User])
async def get_all_users(db: AsyncSession = Depends(get_db)):
    users_dict = await crud.get_users(db)
    users_list = [schemas.User(id=user_id, **user_info) for user_id, user_info in users_dict.items()]
    return users_list

@router.get("/check_email")
async def check_email(email: str, db: AsyncSession = Depends(get_db)):
    user = await crud.get_user_by_email(db, email=email)
    if user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return {"available": True}

@router.get("/check_email_for_medic")
async def check_email_for_medic(email: str, db: AsyncSession = Depends(get_db)):
    db_medic = await crud.get_medic_by_email(db, email=email)
    if db_medic:
        raise HTTPException(status_code=400, detail="Email already registered")
    return {"available": True}
