from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.auth import create_access_token
from . import sql_models, schemas
from sqlalchemy import func
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
from .utils.encryption_utils import encrypt_data, decrypt_data

ph = PasswordHasher()

async def get_user_by(db: AsyncSession, user_id: int):
    result = await db.execute(select(sql_models.User).filter(sql_models.User.id == user_id))
    return result.scalars().first()

async def get_user_by_email(db: AsyncSession, email: str):
    result = await db.execute(select(sql_models.User).filter(sql_models.User.email == email))
    return result.scalars().first()

async def create_user(db: AsyncSession, user: schemas.UserCreate):
    hashed_password = ph.hash(user.password)
    encrypted_first_name = encrypt_data(user.first_name)
    encrypted_last_name = encrypt_data(user.last_name)

    db_user = sql_models.User(
        first_name=encrypted_first_name,
        last_name=encrypted_last_name,
        email=user.email,
        password=hashed_password,
        is_admin=False
    )
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
        print(f"Encrypted first_name: {user.first_name}")  # Check stored value

        try:
            first_name = decrypt_data(user.first_name)
            last_name = decrypt_data(user.last_name)
            email = user.email
            password = user.password
        except Exception as e:
            print(f"Decryption error: {e}")
            continue  

        user_info = {
            "first_name": first_name,
            "last_name": last_name,
            "email": email,
            "password": password,
            "is_admin": user.is_admin
        }
        print(f"Decrypted first_name: {first_name}")
        print(f"Decrypted last_name: {last_name}")
        users_dict[user.id] = user_info

    return users_dict
