from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from ..schemas import user_schemas
from ..crud.user import get_users
from ..database.connection import get_db

router = APIRouter()

@router.get("/users", response_model=List[user_schemas.UserSchema])
async def get_all_users(db: AsyncSession = Depends(get_db)):
    users_dict = await get_users(db)
    users_list = [user_schemas.UserSchema(id=user_id, **user_info) for user_id, user_info in users_dict.items()]
    return users_list

