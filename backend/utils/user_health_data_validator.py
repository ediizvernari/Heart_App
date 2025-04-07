from fastapi import HTTPException
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from .. import sql_models
from sqlalchemy import func

async def check_user_has_health_data(user_id: int, db: AsyncSession) -> bool:
    print(f"DEBUG: Checking if user {user_id} has health data.")

    try:
        result = await db.execute(
            select(sql_models.UserHealthData).filter(sql_models.UserHealthData.user_id == user_id)
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