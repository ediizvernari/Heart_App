from sqlalchemy.future import select
from sqlalchemy import update
from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.utils import create_entity
from backend.database.sql_models import MedicalService, MedicalServiceType

#Medical Service Type functions
async def get_all_encrypted_medical_service_types(db: AsyncSession):
    result = await db.execute(select(MedicalServiceType))
    return result.scalars().all()

#TODO: Also create a function which checks if there is a medical service having the id
async def get_medical_service_by_id(db: AsyncSession, medical_service_id: int) -> MedicalService | None:
    result = await db.execute(
        select(MedicalService)
        .where(MedicalService.id == medical_service_id)
    )
    return result.scalar_one_or_none()

async def get_encrypted_medical_service_type_by_id(db: AsyncSession, medical_service_id: int) -> MedicalService | None:
    result = await db.execute(
        select(MedicalService)
        .where(MedicalService.id == medical_service_id)
    )
    return result.scalar_one_or_none()


#Medical Service functions
async def create_medical_service_entity(db: AsyncSession, **medical_service_arguments) -> MedicalService:
    return await create_entity(db, MedicalService, **medical_service_arguments)


async def get_all_encrypted_medical_services_for_medic(db: AsyncSession, medic_id: int) -> list[MedicalService]:
    result = await db.execute(
        select(MedicalService)
        .where(MedicalService.medic_id == medic_id)
    )
    return result.scalars().all()

async def get_encrypted_medical_service_by_id(db: AsyncSession, medical_service_id: int) -> MedicalService | None:
    result = await db.execute(
        select(MedicalService)
        .where(MedicalService.id == medical_service_id)
    )
    return result.scalar_one_or_none()


async def update_medical_service(db: AsyncSession, medical_service_id: int, values: dict) -> None:
    await db.execute(
        update(MedicalService)
        .where(MedicalService.id == medical_service_id)
        .values(**values)
    )
    await db.commit()