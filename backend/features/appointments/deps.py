from typing       import AsyncGenerator
from fastapi      import Depends
from sqlalchemy.ext.asyncio import AsyncSession
from backend.database.connection import get_db
from backend.features.appointments.core.appointment_repository import AppointmentRepository
from backend.features.appointments.medic_availability.medic_availability_repository import MedicAvailabilityRepository
from backend.features.appointments.suggestions.appointment_suggestions_repository import AppointmentSuggestionRepository
from backend.features.appointments.suggestions.appointment_suggestions_service import AppointmentSuggestionService
from backend.features.medical_service.deps import get_medical_service_svc

from .scheduling.scheduling_service import SchedulingService
from backend.features.medical_service.medical_service    import MedicalServiceService
from backend.features.appointments.medic_availability.medic_availability_service import MedicAvailabilityService
from backend.features.appointments.core.appointment_service import AppointmentService

async def get_appointment_repo(db: AsyncSession = Depends(get_db)) -> AsyncGenerator[AppointmentRepository, None]:
    yield AppointmentRepository(db)

async def get_medic_availability_repo(db: AsyncSession = Depends(get_db)) -> AsyncGenerator[MedicAvailabilityRepository, None]:
    yield MedicAvailabilityRepository(db)

async def get_suggestion_repo(db: AsyncSession = Depends(get_db)) -> AsyncGenerator[AppointmentSuggestionRepository, None]:
    yield AppointmentSuggestionRepository(db)

async def get_medic_availability_service(medic_availability_repo: MedicAvailabilityRepository = Depends(get_medic_availability_repo)) -> AsyncGenerator[MedicAvailabilityService, None]:
    yield MedicAvailabilityService(medic_availability_repo)

async def get_scheduling_service(db: AsyncSession = Depends(get_db), medical_service_service: MedicalServiceService = Depends(get_medical_service_svc), medic_availability_service: MedicAvailabilityService = Depends(get_medic_availability_service), appointment_repo: AppointmentRepository = Depends(get_appointment_repo)) -> AsyncGenerator[SchedulingService, None]:
    yield SchedulingService(db, appointment_repo, medical_service_service, medic_availability_service)

async def get_appointment_service(repo: AppointmentRepository = Depends(get_appointment_repo), scheduling_service = Depends(get_scheduling_service), medical_service_service: MedicalServiceService = Depends(get_medical_service_svc)) -> AsyncGenerator[AppointmentService, None]:
    yield AppointmentService(repo, scheduling_service, medical_service_service)

async def get_suggestion_service(repo: AppointmentSuggestionRepository = Depends(get_suggestion_repo), ms_svc = Depends(get_medical_service_svc)) -> AsyncGenerator[AppointmentSuggestionService, None]:
    yield AppointmentSuggestionService(repo, ms_svc)
