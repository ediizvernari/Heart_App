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
        password=hashed_password
    )
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user

async def create_or_update_user_health_data(db: AsyncSession, user_id: int, personal_data: schemas.UserHealthData):
    try:
        print(f"[DEBUG] Received personal data for user_id={user_id}")

        # Prepare encrypted data where all values are stored as strings (encrypted)
        encrypted_data = {
            "birth_date": encrypt_data(str(personal_data.birth_date)),
            "height": encrypt_data(str(personal_data.height)),  # Ensure all fields are encrypted as strings
            "weight": encrypt_data(str(personal_data.weight)),  # Same for weight
            "cholesterol_level": encrypt_data(str(personal_data.cholesterol_level)),
            "ap_hi": encrypt_data(str(personal_data.ap_hi)),
            "ap_lo": encrypt_data(str(personal_data.ap_lo))
        }

        print(f"[DEBUG] Encrypted data keys for user_id={user_id}: {list(encrypted_data.keys())}")

        existing_data = await db.execute(
            select(sql_models.UserHealthData).filter(sql_models.UserHealthData.user_id == user_id)
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
            db_personal_data = sql_models.UserHealthData(user_id=user_id, **encrypted_data)
            db.add(db_personal_data)
            await db.commit()
            await db.refresh(db_personal_data)
            print(f"[DEBUG] Successfully created data for user_id={user_id}")
            return db_personal_data

    except Exception as e:
        await db.rollback()  # Roll back transaction on failure
        print(f"[ERROR] Database error for user_id={user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

#TODO: Change the signature of this to return a list of users and their health data
async def get_all_users_health_data(db: AsyncSession):
    result = await db.execute(select(sql_models.UserHealthData))
    users_health_data = result.scalars().all()
    users_health_data_dict = {}

    for user_health_data in users_health_data:
        try:
            birth_date = decrypt_data(user_health_data.birth_date)
            height = decrypt_data(user_health_data.height)
            weight = decrypt_data(user_health_data.weight)
            cholesterol_level = decrypt_data(user_health_data.cholesterol_level)
            ap_hi = decrypt_data(user_health_data.ap_hi)
            ap_lo = decrypt_data(user_health_data.ap_lo)
        except Exception as e:
            print(f"Decryption error: {e}")
            continue  

        user_info = {
            "birth_date": birth_date,
            "height": height,
            "weight": weight,
            "cholesterol_level": cholesterol_level,
            "ap_hi": ap_hi,
            "ap_lo": ap_lo,
        }
        users_health_data_dict[user_health_data.user_id] = user_info

    return users_health_data_dict

async def get_medical_record(db: AsyncSession, record_id: int):
    result = await db.execute(select(sql_models.MedicalRecord).filter(sql_models.MedicalRecord.id == record_id))
    return result.scalars().first()

async def create_medical_record(db: AsyncSession, record: schemas.MedicalRecordCreate):
    db_record = sql_models.MedicalRecord(**record.model_dump())
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
        }
        print(f"Decrypted first_name: {first_name}")
        print(f"Decrypted last_name: {last_name}")
        users_dict[user.id] = user_info

    return users_dict
