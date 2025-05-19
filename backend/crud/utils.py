from typing import Optional, Type, TypeVar, Any, Sequence
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import DeclarativeMeta, InstrumentedAttribute

T = TypeVar("T", bound=DeclarativeMeta)
F = TypeVar("F")

async def create_entity(
    db: AsyncSession,
    model: Type[T],
    **arguments: Any
) -> T:
    
    created_object = model(**arguments)
    db.add(created_object)
    await db.commit()
    await db.refresh(created_object)
    return created_object

async def update_entity_by_id(
    db: AsyncSession,
    model: Type[T],
    object_id: int,
    values = dict[str, Any]
) -> None:
    
    update_statement = (
        update(model)
        .where(model.id == object_id)
        .values(**values)
    )
    await db.execute(update_statement)
    await db.commit()

async def delete_entity_by_id(
    db: AsyncSession,
    model: Type[T],
    object_id: int
) -> None:
    
    object = await db.get(model, object_id)
    if object is not None:
        await db.delete(object)
        await db.commit()

async def get_entity_by_id(
    db: AsyncSession,
    model: Type[T],
    object_id: int
) -> T | None:
    
    result = await db.execute(
        select(model)
        .where(model.id == object_id)
    )

    return result.scalar_one_or_none()

async def list_entities(
    db: AsyncSession,
    model: Type[T],
    *,
    filters: Sequence[Any] = (),
    order_by: Any = None
) -> list[T]:
    
    listing_statement = select(model)

    for filter in filters:
        listing_statement = listing_statement.where(filter)
    if order_by is not None:
        listing_statement = listing_statement.order_by(order_by)
    
    result = await db.execute(listing_statement)
    return result.scalars().all()

async def get_entity_by_field(
    db: AsyncSession,
    model: Type[T],
    *filters: Any,
) -> Optional[T]:
    statement = select(model)
    for filter in filters:
        statement = statement.where(filter)
    result = await db.execute(statement)
    return result.scalars().first()

async def get_entity_field_by_id(
    db: AsyncSession,
    model: Type[T],
    field: InstrumentedAttribute[F],
    object_id: int,
    id_attr: InstrumentedAttribute
) -> Optional[F]:
    id_col = id_attr or getattr(model, "id")
    statement = select(field).where(id_col == object_id)
    result = await db.execute(statement)
    return result.scalar_one_or_none()