import asyncio
import sys
from fastapi import FastAPI
from backend.database.connection import SessionLocal, engine, Base
from backend.routers import appointment_suggestions, appointments, medic_availability, medical_service, scheduling, user_health_data, user_medical_records, users, auth, cvd_prediction, medics, location
from fastapi.middleware.cors import CORSMiddleware
from backend.utils.medical_service_seed import seed_cardiology_medical_service_types

if sys.platform.startswith("win"):
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

async def create_tables():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

app = FastAPI()

async def on_startup():
    await create_tables()
    async with SessionLocal() as db:
        await seed_cardiology_medical_service_types(db)

origins = [
    "https://10.0.2.2",
    "https://10.0.2.2:8000",
    "https://localhost",
    "https://localhost:8000",
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

#TODO: Not the place but maybe add a message schema, also add the medical services and appointments schemas
app.include_router(users.router, prefix="/users")
app.include_router(user_health_data.router, prefix="/user_health_data")
app.include_router(auth.router, prefix="/auth")
app.include_router(cvd_prediction.router, prefix="/cvd_prediction")
app.include_router(location.router, prefix="/location")
app.include_router(medics.router, prefix="/medics")
app.include_router(user_medical_records.router, prefix="/user_medical_records")
app.include_router(scheduling.router, prefix="/scheduling")
app.include_router(medical_service.router, prefix="/medical_service")
app.include_router(appointments.router, prefix="/appointments")
app.include_router(appointment_suggestions.router, prefix="/suggestions")
app.include_router(medic_availability.router, prefix="/medic_availability")
