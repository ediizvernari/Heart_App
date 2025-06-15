from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.utils import create_entity, get_entity_by_field, update_entity_by_id
from ...database.sql_models import User

class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, **user_arguments) -> User:
        return await create_entity(self.db, User, **user_arguments)

    async def get_by_email(self, email: str) -> Optional[User]:
        return await get_entity_by_field(self.db, User, User.email==email)

    async def get_user_by_id(self, user_id: int) -> Optional[User]:
        return await get_entity_by_field(self.db, User, User.id==user_id)
    
    async def assign_medic(self, user_id: int, medic_id: int) -> None:
        await update_entity_by_id(self.db, User, user_id, {"medic_id": medic_id})
    
    async def unassign_medic(self, user_id: int) -> None:
        await update_entity_by_id(self.db, User, user_id, {"medic_id": None})

#TODO: Maybe add some password change and also a delete for accound deletion