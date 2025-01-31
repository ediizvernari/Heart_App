from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from .. import crud, schemas
from ..database import get_db

router = APIRouter()

# Create a new user
@router.post("/", response_model=schemas.User)
async def create_user(user: schemas.UserCreate, db: AsyncSession = Depends(get_db)):
    db_user = await crud.get_user_by_username(db, username=user.username)
    if db_user:
        #TODO: Check the error code
        raise HTTPException(status_code=400, detail="Username already registered")
    return await crud.create_user(db=db, user=user)

@router.get("/users", response_model=List[schemas.User])
async def get_all_users(db: AsyncSession = Depends(get_db)):
    users_dict = await crud.get_users(db)
    users_list = [schemas.User(id=user_id, **user_info) for user_id, user_info in users_dict.items()]
    return users_list
