from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.repository.generic_repository import GenericRepository
from backend.core.database.sql_models import User

class UserRepository(GenericRepository[User]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, User)

    async def get_by_email(self, email: str) -> Optional[User]:
        users = await self.list(filters=[User.email==email])
        return users[0] if users else None

    async def get_user_by_id(self, user_id: int) -> Optional[User]:
        return await self.get_by_id(user_id)

    async def assign_medic(self, user_id: int, medic_id: int) -> None:
        print(f"[INFO] Assigning medic {medic_id} to user {user_id}")
        await self.update(user_id, {"medic_id":medic_id})

    async def unassign_medic(self, user_id: int) -> None:
        print(f"[INFO] Unassigning medic from user {user_id}")
        await self.update(user_id, {"medic_id":None})