from fastapi import HTTPException
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from ..schemas.user_health_data_schemas import UserHealthDataSchema
from backend.utils.encryption_utils import decrypt_data, decrypt_health_data_fields_for_user, encrypt_data
from ..database.sql_models import UserHealthData

async def check_user_has_health_data(db: AsyncSession, user_id: int) -> bool:
    print(f"DEBUG: Checking if user {user_id} has health data.")

    try:
        result = await db.execute(
            select(UserHealthData).filter(UserHealthData.user_id == user_id)
        )
        health_data = result.scalar_one_or_none()

        if health_data:
            print(f"DEBUG: User {user_id} has health data.")
            return True
        else:
            print(f"DEBUG: User {user_id} does not have health data.")
            return False
    except Exception as e:
        print(f"DEBUG: Error checking health data for user {user_id}: {e}")
        return False


async def create_or_update_user_health_data_for_user(db: AsyncSession, user_id: int, user_health_data: UserHealthDataSchema):
    try:
        print(f"[DEBUG] Received personal data for user_id={user_id}")

        encrypted_data = {
            "birth_date": encrypt_data(str(user_health_data.birth_date)),
            "height": encrypt_data(str(user_health_data.height)),
            "weight": encrypt_data(str(user_health_data.weight)),
            "cholesterol_level": encrypt_data(str(user_health_data.cholesterol_level)),
            "ap_hi": encrypt_data(str(user_health_data.ap_hi)),
            "ap_lo": encrypt_data(str(user_health_data.ap_lo))
        }

        existing_data = await db.execute(
            select(UserHealthData).filter(UserHealthData.user_id == user_id)
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
            db_personal_data = UserHealthData(user_id=user_id, **encrypted_data)
            db.add(db_personal_data)
            await db.commit()
            await db.refresh(db_personal_data)
            print(f"[DEBUG] Successfully created data for user_id={user_id}")
            return db_personal_data

    except Exception as e:
        await db.rollback()
        print(f"[ERROR] Database error for user_id={user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


#TODO: Change the signature of this to return a list of users and their health data
async def get_all_users_health_data(db: AsyncSession):
    result = await db.execute(select(UserHealthData))
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


async def get_user_health_data_for_user_id(db: AsyncSession, user_id: int) -> UserHealthDataSchema:
    print(f"[DEBUG] Fetching health data for user_id={user_id}")
    try:
        result = await db.execute(
            select(UserHealthData).filter(UserHealthData.user_id == user_id)
        )
        encrypted_user_health_data = result.scalar_one()

        print(f"[DEBUG] Found health data for user_id={user_id}")

        encrypted_user_health_data_dict = dict(encrypted_user_health_data.__dict__)
        encrypted_user_health_data_dict.pop('_sa_instance_state', None) # Remove SQLAlchemy state

        decrypted_user_health_data = decrypt_health_data_fields_for_user(encrypted_user_health_data_dict)

        for key, value in decrypted_user_health_data.items():
            print(f"[DEBUG] Decrypted {key}: {value}")

        return UserHealthDataSchema(**decrypted_user_health_data)
    except Exception as e:
        print(f"[ERROR] Error fetching health data for user_id={user_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Error fetching health data: {str(e)}")


async def get_parsed_user_health_data(db: AsyncSession, user_id: int) -> dict:
    result = await db.execute(
        select(UserHealthData).filter(UserHealthData.user_id == user_id)
    )
    encrypted_user_health_data = result.scalar_one()
    print(f"[DEBUG] The data for user_id={user_id} is aaa{encrypted_user_health_data.ap_hi}")
    encrypted_user_health_data_dict = dict(encrypted_user_health_data.__dict__)
    encrypted_user_health_data_dict.pop('_sa_instance_state', None)

    decrypted_user_health_data_dict = decrypt_health_data_fields_for_user(encrypted_user_health_data_dict)

    user_data_for_input_feature_build = UserHealthDataSchema(**decrypted_user_health_data_dict)

    return {
        "birth_date": user_data_for_input_feature_build.birth_date,
        "height": user_data_for_input_feature_build.height,
        "weight": user_data_for_input_feature_build.weight,
        "cholesterol_level": user_data_for_input_feature_build.cholesterol_level,
        "ap_hi": user_data_for_input_feature_build.ap_hi,
        "ap_lo": user_data_for_input_feature_build.ap_lo,
    }
