from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from .. import crud, schemas
from ..auth import get_current_user
from ..database import get_db

router = APIRouter()

@router.post("/")
async def create_or_update_personal_data(
    personal_data: schemas.UserPersonalData,
    db: AsyncSession = Depends(get_db),
    current_user: schemas.User = Depends(get_current_user)
):
    user_id = current_user.id 
    await crud.create_or_update_personal_data(db=db, user_id=user_id, personal_data=personal_data)
    return {"status": "success"}

