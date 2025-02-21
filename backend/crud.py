from fastapi import HTTPException   #TODO: Maybe move this check into the router file
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from . import sql_models, schemas
from sqlalchemy import func
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
from .utils.encryption_utils import encrypt_data, decrypt_data

ph = PasswordHasher()

async def get_user_by_id(db: AsyncSession, user_id: int):
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

async def create_or_update_personal_data(db: AsyncSession, user_id: int, personal_data: schemas.UserPersonalData):
    try:
        print(f"[DEBUG] Received personal data for user_id={user_id}")

        # Prepare encrypted data where all values are stored as strings (encrypted)
        encrypted_data = {
            "birth_date": encrypt_data(str(personal_data.birth_date)),
            "height": encrypt_data(str(personal_data.height)),  # Ensure all fields are encrypted as strings
            "weight": encrypt_data(str(personal_data.weight)),  # Same for weight
            "is_male": encrypt_data(str(personal_data.is_male)),  # Encrypt even boolean fields as strings
            "education": encrypt_data(str(personal_data.education)),
            "current_smoker": encrypt_data(str(personal_data.current_smoker)),
            "cigs_per_day": encrypt_data(str(personal_data.cigs_per_day)),
            "BPMeds": encrypt_data(str(personal_data.BPMeds)),
            "prevalentStroke": encrypt_data(str(personal_data.prevalentStroke)),
            "prevalentHyp": encrypt_data(str(personal_data.prevalentHyp)),
            "diabetes": encrypt_data(str(personal_data.diabetes)),
            "totChol": encrypt_data(str(personal_data.totChol)),
            "glucose": encrypt_data(str(personal_data.glucose)),
        }

        print(f"[DEBUG] Encrypted data keys for user_id={user_id}: {list(encrypted_data.keys())}")

        existing_data = await db.execute(
            select(sql_models.UserPersonalData).filter(sql_models.UserPersonalData.user_id == user_id)
        )
        existing_data = existing_data.scalars().first()

        if existing_data:
            print(f"[DEBUG] Updating existing personal data for user_id={user_id}")
            for key, value in encrypted_data.items():
                setattr(existing_data, key, value)

            db.add(existing_data)
            await db.commit()
            await db.refresh(existing_data)
            print(f"[DEBUG] Successfully updated data for user_id={user_id}")
            return existing_data
        else:
            print(f"[DEBUG] Creating new personal data entry for user_id={user_id}")
            db_personal_data = sql_models.UserPersonalData(user_id=user_id, **encrypted_data)
            db.add(db_personal_data)
            await db.commit()
            await db.refresh(db_personal_data)
            print(f"[DEBUG] Successfully created data for user_id={user_id}")
            return db_personal_data

    except Exception as e:
        await db.rollback()  # Roll back transaction on failure
        print(f"[ERROR] Database error for user_id={user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


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
