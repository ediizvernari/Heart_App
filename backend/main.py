import asyncio
from fastapi import FastAPI, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database import engine, Base, get_db
from backend import crud, schemas
from typing import List
from backend.routers import users
from fastapi.middleware.cors import CORSMiddleware

async def create_tables():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

app = FastAPI()

async def on_startup():
    await create_tables()

origins = [
    "http://10.0.2.2",
    "http://10.0.2.2:8000",
    "http://localhost",
    "http://localhost:8000",
]

app.add_event_handler("startup", on_startup)

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def read_root():
    return {"message": "Welcome to the FastAPI application"}

app.include_router(users.router, prefix="/users")