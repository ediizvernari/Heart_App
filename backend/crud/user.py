from fastapi import HTTPException   #TODO: Maybe move this check into the router file
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from argon2 import PasswordHasher
from ..database.sql_models import User
from ..schemas.user_schemas import UserCreateSchema
from ..utils.encryption_utils import encrypt_data, decrypt_data

ph = PasswordHasher()

async def create_user(db: AsyncSession, user: UserCreateSchema):
    hashed_password = ph.hash(user.password)
    encrypted_first_name = encrypt_data(user.first_name)
    encrypted_last_name = encrypt_data(user.last_name)

    db_user = User(
        first_name=encrypted_first_name,
        last_name=encrypted_last_name,
        email=user.email,
        password=hashed_password
    )
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user

async def get_user_by_email(db: AsyncSession, email: str):
    result = await db.execute(select(User).filter(User.email == email))
    return result.scalars().first()

async def get_user_by_id(db: AsyncSession, user_id: int):
    result = await db.execute(select(User).filter(User.id == user_id))
    return result.scalars().first()

#TODO: Modify this function and place it into the services file once I modify it to get the users for a specified medic
async def get_users(db: AsyncSession):
    result = await db.execute(select(User))
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