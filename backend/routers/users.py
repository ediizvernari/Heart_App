from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from jose import jwt #Remove this line after verifications
from .. import crud, schemas
from ..auth import ALGORITHM, SECRET_KEY, create_access_token, verify_password, get_current_user
from ..database import get_db

router = APIRouter()

@router.post("/", response_model=schemas.Token)
async def create_user(user: schemas.UserCreate, db: AsyncSession = Depends(get_db)):
    db_user = await crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    user = await crud.create_user(db=db, user=user)
    access_token = create_access_token(data={"sub": user.email})
    print("Decoded email: ") #TODO: Remove this line and the next
    print(jwt.decode(access_token, SECRET_KEY, algorithms=[ALGORITHM]))
    return schemas.Token(access_token=access_token, token_type="bearer")

@router.post("/login", response_model=schemas.Token)
async def login_for_access_token(login: schemas.Login, db: AsyncSession = Depends(get_db)):
    user = await crud.get_user_by_email(db, email=login.email)
    if not user or not verify_password(login.password, user.password):
        raise HTTPException(
            status_code=400,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(data={"sub": user.email})
    return schemas.Token(access_token=access_token, token_type="bearer")

@router.get("/me", response_model=schemas.User, description="Get the current logged-in user")
async def read_users_me(current_user: schemas.User = Depends(get_current_user)):
    print("verificare")
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