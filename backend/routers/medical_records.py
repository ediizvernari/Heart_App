from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from ..schemas.medical_records_schemas import MedicalRecord, MedicalRecordCreate
from ..crud.user import get_user_by_id
from ..crud.medical_record import create_medical_record, get_medical_record
from ..database.connection import get_db

router = APIRouter(
    prefix="/medical_records",
    tags=["medical_records"],
    responses={404: {"description": "Not found"}}
    )

@router.post("/", response_model=MedicalRecord)
async def create_medical_record(medical_record: MedicalRecordCreate, db: AsyncSession = Depends(get_db)):
    db_user = await get_user_by_id(db, user_id=medical_record.user_id)
    if not db_user:
        raise HTTPException(status_code=400, detail="User not found")
    return await create_medical_record(db=db, medical_record=medical_record)

# Get all medical records base on the user ID
@router.get("/medical_records/{record_id}", response_model=MedicalRecord)
async def read_medical_record(record_id: int, db: AsyncSession = Depends(get_db)):
    db_record = await get_medical_record(db, record_id=record_id)
    if db_record is None:
        raise HTTPException(status_code=404, detail="Medical record not found")
    return db_record   