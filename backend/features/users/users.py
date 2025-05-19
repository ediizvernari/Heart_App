from typing import List
from fastapi import APIRouter, Depends, HTTPException, status

from backend.database.sql_models import User
from backend.features.auth.deps      import get_current_account
from backend.features.users.deps     import get_user_service
from backend.features.users.user_schemas import (
    UserCreateSchema,
    UserOutSchema,
    MedicAssignmentRequest,
    UserAssignmentStatus,
)
from backend.features.medics.medic_schemas import MedicOutSchema
from backend.features.auth.auth_schemas     import MessageSchema
from backend.features.users.user_service import UserService

router = APIRouter()

@router.get("/me/has_medic", response_model=bool)
async def check_if_user_has_medic(current_user: User = Depends(get_current_account)):
    return {"has_medic": current_user.medic_id is not None}

@router.get("/assignment_status", response_model=UserAssignmentStatus)
async def get_current_user_assignment_status(current_user: User = Depends(get_current_account), user_service: UserService = Depends(get_user_service)):
    return await user_service.get_user_assignment_status(current_user.id)

@router.post("/assign_medic", response_model=MessageSchema)
async def assign_medic_to_current_user(medic_assignment_request: MedicAssignmentRequest, current_user: User = Depends(get_current_account), user_service: UserService = Depends(get_user_service)):
    await user_service.assign_user_to_medic(current_user.id, medic_assignment_request.medic_id)
    return {"message": "Medic assigned successfully"}

@router.patch("/share_data", response_model=MessageSchema)
async def change_sharing_data_preference(share_data_with_medic: bool, current_user: User = Depends(get_current_account), user_service: UserService = Depends(get_user_service)):
    await user_service.update_user_sharing_preferences(current_user.id, share_data_with_medic)
    return {"message": "Sharing data preference updated successfully"}

@router.get("/assigned_medic", response_model=MedicOutSchema)
async def get_current_user_assigned_medic(current_user: User = Depends(get_current_account), user_service: UserService = Depends(get_user_service)):
    return await user_service.get_assigned_medic(current_user.id)

@router.get("/unassign_medic", response_model=MessageSchema)
async def unassign_medic_from_current_user(current_user: User = Depends(get_current_account), user_service: UserService = Depends(get_user_service)):
    await user_service.unassign_medic(current_user.id)
    return {"message": "Medic unassigned successfully"}
