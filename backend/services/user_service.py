from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from ..crud.user import get_user_by_id, get_user_by_email, create_user
from ..schemas.user_schemas import UserSchema, UserCreateSchema
from ..core.auth import create_access_token

async def signup_user(db: AsyncSession, user: UserCreateSchema):
    is_user_found = await get_user_by_email(db, email=user.email)
    if is_user_found:
        raise HTTPException(status_code=400, detail="A user with the same email is already registered")
    created_user = await create_user(db=db, user=user)
    access_token = create_access_token(data={"sub": created_user.id, "role": "user"})
    return access_token

async def check_user_email_availability(db: AsyncSession, email: str):
    is_user_found = await get_user_by_email(db, email=email)
    if is_user_found:
        raise HTTPException(status_code=400, detail="Email already registered")
    return {"available": True}