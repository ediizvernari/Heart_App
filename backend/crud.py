from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from . import sql_models, schemas
from sqlalchemy import func

async def get_user_by(db: AsyncSession, user_id: int):
    result = await db.execute(select(sql_models.User).filter(sql_models.User.id == user_id))
    return result.scalars().first()

async def get_user_by_email(db: AsyncSession, email: str):
    result = await db.execute(select(sql_models.User).filter(sql_models.User.email == email))
    return result.scalars().first()

async def create_user(db: AsyncSession, user: schemas.UserCreate):
    db_user = sql_models.User(first_name=user.first_name, last_name=user.last_name, email=user.email, password=user.password)
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user

async def get_medical_record(db: AsyncSession, record_id: int):
    result = await db.execute(select(sql_models.MedicalRecords).filter(sql_models.MedicalRecords.id == record_id))
    return result.scalars().first()

async def create_medical_record(db: AsyncSession, record: schemas.MedicalRecordsCreate):
    db_record = sql_models.MedicalRecords(**record.model_dump())
    db.add(db_record)
    await db.commit()
    await db.refresh(db_record)
    return db_record

async def get_users(db: AsyncSession):
    result = await db.execute(select(sql_models.User))
    users = result.scalars().all()
    users_dict = {}
    for user in users:
        print(user.first_name + " " + user.last_name)
        user_info = {
            "first_name": user.first_name,
            "last_name": user.last_name,
            "email": user.email,
            "password": user.password,
            "is_admin": user.is_admin
        }
        users_dict[user.id] = user_info
    return users_dict