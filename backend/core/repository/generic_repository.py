import logging
from typing import Generic, Type, TypeVar, Any, Sequence, Optional
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import DeclarativeMeta

T = TypeVar("T", bound=DeclarativeMeta)
logger = logging.getLogger(__name__)

class GenericRepository(Generic[T]):
    def __init__(self, db: AsyncSession, model: Type[T]):
        self.db = db
        self.model = model

    async def create(self, **kwargs: Any) -> T:
        logger.debug("Creating %s with %r", self.model.__name__, kwargs)
        obj = self.model(**kwargs)
        self.db.add(obj)
        await self.db.commit()
        await self.db.refresh(obj)
        logger.info("Created %s id=%s", self.model.__name__, getattr(obj, "id", None))
        return obj

    async def update(self, object_id: int, values: dict[str, Any]) -> None:
        logger.debug("Updating %s id=%s with %r", self.model.__name__, object_id, values)
        stmt = update(self.model).where(self.model.id == object_id).values(**values)
        await self.db.execute(stmt)
        await self.db.commit()
        logger.info("Updated %s id=%s", self.model.__name__, object_id)

    async def get_by_id(self, object_id: int) -> Optional[T]:
        logger.debug("Getting %s by id=%s", self.model.__name__, object_id)
        result = await self.db.execute(select(self.model).where(self.model.id == object_id))
        return result.scalar_one_or_none()

    async def list(
        self,
        filters: Sequence[Any] = (),
        order_by: Any = None
    ) -> list[T]:
        logger.debug("Listing %s with filters=%r order_by=%s", self.model.__name__, filters, order_by)
        stmt = select(self.model)
        for f in filters:
            stmt = stmt.where(f)
        if order_by:
            stmt = stmt.order_by(order_by)
        result = await self.db.execute(stmt)
        return result.scalars().all()

    async def delete(self, object_id: int) -> None:
        logger.debug("Deleting %s id=%s", self.model.__name__, object_id)
        obj = await self.get_by_id(object_id)
        if obj:
            await self.db.delete(obj)
            await self.db.commit()
            logger.info("Deleted %s id=%s", self.model.__name__, object_id)
