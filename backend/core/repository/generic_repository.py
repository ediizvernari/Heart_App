from typing import Generic, Type, TypeVar, Any, Sequence, Optional
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import DeclarativeMeta

T = TypeVar("T", bound=DeclarativeMeta)

class GenericRepository(Generic[T]):
    def __init__(self, db: AsyncSession, model: Type[T]):
        self.db = db
        self.model = model

    async def create(self, **kwargs: Any) -> T:
        print(f"[DEBUG] Creating {self.model.__name__} with {kwargs!r}")
        obj = self.model(**kwargs)
        self.db.add(obj)
        await self.db.commit()
        await self.db.refresh(obj)
        print(f"[INFO] Created {self.model.__name__} id={getattr(obj, 'id', None)}")
        return obj

    async def update(self, object_id: int, values: dict[str, Any]) -> None:
        print(f"[DEBUG] Updating {self.model.__name__} id={object_id} with {values!r}")
        stmt = update(self.model).where(self.model.id == object_id).values(**values)
        await self.db.execute(stmt)
        await self.db.commit()
        print(f"[INFO] Updated {self.model.__name__} id={object_id}")

    async def get_by_id(self, object_id: int) -> Optional[T]:
        print(f"[DEBUG] Getting {self.model.__name__} by id={object_id}")
        result = await self.db.execute(select(self.model).where(self.model.id == object_id))
        return result.scalar_one_or_none()
    
    async def get_by_field(self, *filters: Any ) -> Optional[T]:
        print(f"[DEBUG] Getting {self.model.__name__} by filters={filters!r}")
        statement = select(self.model)
        for filter in filters:
            statement = statement.where(filter)
        result = await self.db.execute(statement)
        return result.scalars().first()

    async def list(self, filters: Sequence[Any] = (), order_by: Any = None) -> list[T]:
        print(f"[DEBUG] Listing {self.model.__name__} with filters={filters!r} order_by={order_by}")
        stmt = select(self.model)
        for f in filters:
            stmt = stmt.where(f)
        if order_by:
            stmt = stmt.order_by(order_by)
        result = await self.db.execute(stmt)
        return result.scalars().all()

    async def delete(self, object_id: int) -> None:
        print(f"[DEBUG] Deleting {self.model.__name__} id={object_id}")
        obj = await self.get_by_id(object_id)
        if obj:
            await self.db.delete(obj)
            await self.db.commit()
            print(f"[INFO] Deleted {self.model.__name__} id={object_id}")
