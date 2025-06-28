from pathlib import Path

from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    db_user: str = "postgres"
    db_pass: str = "123456"
    db_host: str = "localhost"
    db_port: int = 5432
    db_name: str = "health_app_db"

    @property
    def sqlalchemy_database_url(self) -> str:
        return (
            f"postgresql+asyncpg://"
            f"{self.db_user}:{self.db_pass}@"
            f"{self.db_host}:{self.db_port}/"
            f"{self.db_name}"
        )

    class Config:
        env_file = ".env"

settings = Settings()

BASE_DIR     = Path(__file__).resolve().parent
ML_MODELS_DIR = BASE_DIR / "ml_files"

ENCRYPTED_USER_HEALTH_DATA_FIELDS = [
    "birth_date",
    "height",
    "weight",
    "cholesterol_level",
    "ap_hi",
    "ap_lo",
]

ENCRYPTED_APPOINTMENT_FIELDS = [
    "address",
    "medical_service_name",
    "medical_service_price",
    "appointment_start",
    "appointment_end",
    "appointment_status",
]

ENCRYPTED_MEDIC_AVAILABILITY_FIELDS = [
    "weekday",
    "start_time",
    "end_time",
]

ENCRYPTED_APPOINTMENT_SUGGESTION_FIELDS=[
    "status",
    "reason",
]

ENCRYPTED_USER_FIELDS=[
    "first_name",
    "last_name",
]

ENCRYPTED_COUNTRY_FIELDS=["name"]

ENCRYPTED_CITY_FIELDS=["name"]

ENCRYPTED_MEDIC_FIELDS = [
    "first_name",
    "last_name",
    "street_address",
]

ENCRYPTED_USER_MEDICAL_RECORD_FIELDS = [
    "birth_date",
    "height",
    "weight",
    "cholesterol_level",
    "ap_hi",
    "ap_lo",
    "cvd_risk",
]

ENCRYPTED_MEDICAL_SERVICE_FIELDS = [
    "name",
    "price",
    "duration_minutes",
]