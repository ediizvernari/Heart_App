from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from .. import crud, schemas
from ..database import get_db

router = APIRouter(
    prefix="/medical_records",
    tags=["medical_records"],
    responses={404: {"description": "Not found"}}
    )

# Create a new medical record
#TODO: Maybe create a function that searches the user by ID
@router.post("/", response_model=schemas.MedicalRecord)
async def create_medical_record(medical_record: schemas.MedicalRecordsCreate, db: AsyncSession = Depends(get_db)):
    db_user = await crud.get_user_by_id(db, user_id=medical_record.user_id)
    if not db_user:
        raise HTTPException(status_code=400, detail="User not found")
    return await crud.create_medical_record(db=db, medical_record=medical_record)

# Get all medical records base on the user ID
@router.get("/medical_records/{record_id}", response_model=schemas.MedicalRecord)
async def read_medical_record(record_id: int, db: AsyncSession = Depends(get_db)):
    db_record = await crud.get_medical_record(db, record_id=record_id)
    if db_record is None:
        raise HTTPException(status_code=404, detail="Medical record not found")
    return db_record   