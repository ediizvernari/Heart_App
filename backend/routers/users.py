from typing import List
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from .. import crud, schemas
from ..auth import create_access_token, verify_password, get_current_user
from ..database import get_db

router = APIRouter()

@router.post("/", response_model=schemas.Token)
async def create_user(user: schemas.UserCreate, db: AsyncSession = Depends(get_db)):
    db_user = await crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    user = await crud.create_user(db=db, user=user)
    access_token = create_access_token(data={"sub": user.email})
    return schemas.Token(access_token=access_token, token_type="bearer")

@router.post("/token", response_model=schemas.Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: AsyncSession = Depends(get_db)):
    user = await crud.get_user_by_email(db, email=form_data.username)
    if not user or not verify_password(form_data.password, user.password):
        raise HTTPException(
            status_code=400,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=schemas.User)
async def read_users_me(current_user: schemas.User = Depends(get_current_user)):
    return current_user

@router.get("/users", response_model=List[schemas.User])
async def get_all_users(db: AsyncSession = Depends(get_db)):
    users_dict = await crud.get_users(db)
    users_list = [schemas.User(id=user_id, **user_info) for user_id, user_info in users_dict.items()]
    return users_list

@router.get("/check_email")
async def check_email(email: str, db: AsyncSession = Depends(get_db)):
    db_user = await crud.get_user_by_email(db, email=email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return {"message": "Email available"}