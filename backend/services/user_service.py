from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.sql_models import User
from ..crud.user import get_user_by_id, get_user_by_email, create_user
from ..schemas.user_schemas import UserAssignmentStatus, UserSchema, UserCreateSchema
from ..core.auth import create_access_token
from .medic import get_existing_medic_by_id

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

#TODO: Might either delete this function or take it as an example for the others
async def get_existing_user_by_id(db: AsyncSession, user_id: int):
    user = await get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

async def update_user_sharing_data_preference(db: AsyncSession, user: User, share_data_with_medic: bool):
    user.share_data_with_medic = share_data_with_medic
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user

async def is_user_assigned_to_medic(db: AsyncSession, current_user: User):
    return current_user.medic_id is not None

async def get_user_assignment_status(user: User) -> UserAssignmentStatus:
    return UserAssignmentStatus(
        has_assigned_medic=user.medic_id is not None,
        shares_data_with_medic=user.share_data_with_medic
    )

async def assign_medic_to_user(db: AsyncSession, current_user: int, medic_id: int):
    current_user.medic_id = medic_id
    db.add(current_user)
    await db.commit()
    await db.refresh(current_user)
    return current_user

async def get_assigned_medic(db: AsyncSession, current_user: User):
    if not current_user.medic_id:
        raise HTTPException(status_code=404, detail="No medic assigned")

    assigned_medic = await get_existing_medic_by_id(db, current_user.medic_id)
    return assigned_medic

async def unassign_medic_from_user(db: AsyncSession, current_user: User):
    current_user.medic_id = None
    current_user.share_data_with_medic = False
    db.add(current_user)
    await db.commit()
    await db.refresh(current_user)
    return current_user
