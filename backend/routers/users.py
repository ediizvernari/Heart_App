from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.sql_models import User
from backend.services.account_service import get_current_account
from ..schemas.user_schemas import UserAssignmentStatus, UserSchema, MedicAssignmentRequest
from ..schemas.medic_schemas import MedicOut
from ..schemas.token_schema import MessageSchema
from ..crud.user import get_users
from ..services.user_service import (
assign_medic_to_user, 
get_assigned_medic,
get_user_assignment_status,
unassign_medic_from_user,
update_user_sharing_data_preference,
)
from ..database.connection import get_db

router = APIRouter()

@router.get("/users", response_model=List[UserSchema])
async def get_all_users(db: AsyncSession = Depends(get_db)):
    users_dict = await get_users(db)
    users_list = [UserSchema(id=user_id, **user_info) for user_id, user_info in users_dict.items()]
    return users_list


@router.get("/me/has_medic", response_model=bool)
async def check_if_user_has_medic(current_user: User = Depends(get_current_account)):
    return {"has_medic": current_user.medic_id is not None}

@router.get("/assignment_status", response_model=UserAssignmentStatus)
async def get_current_user_assignment_status(current_user: User = Depends(get_current_account)):
    return await get_user_assignment_status(current_user)

@router.post("/assign_medic", response_model=MessageSchema)
async def assign_medic_to_current_user(medic_assignment_request: MedicAssignmentRequest, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_account)):
    await assign_medic_to_user(db, current_user, medic_assignment_request.medic_id)
    return {"message": "Medic assigned successfully"}

@router.patch("/share_data", response_model=MessageSchema)
async def change_sharing_data_preference(share_data_with_medic: bool, current_user: User = Depends(get_current_account), db: AsyncSession = Depends(get_db)):
    await update_user_sharing_data_preference(db, current_user, share_data_with_medic)
    return {"message": "Sharing data preference updated successfully"}

@router.get("/assigned_medic", response_model=MedicOut)
async def get_current_user_assigned_medic(current_user: User = Depends(get_current_account), db: AsyncSession = Depends(get_db)):
    return await get_assigned_medic(db, current_user)

@router.get("/unassign_medic", response_model=MessageSchema)
async def unassign_medic_from_current_user(current_user: User = Depends(get_current_account), db: AsyncSession = Depends(get_db)):
    await unassign_medic_from_user(db, current_user)
    return {"message": "Medic unassigned successfully"}
