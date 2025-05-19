from typing    import List
from fastapi   import APIRouter, Depends, status

from backend.database.sql_models import Medic
from backend.features.auth.deps import get_current_account  
from backend.features.appointments.deps import get_medic_availability_service 
from backend.features.appointments.medic_availability.medic_availability_service import MedicAvailabilityService 
from backend.features.appointments.medic_availability.medic_availability_schemas import (
    MedicAvailabilityCreateSchema,
    MedicAvailabilityOutSchema,
)

router = APIRouter()

@router.get("/all", response_model=List[MedicAvailabilityOutSchema])
async def get_medical_availabilities_for_medic(current_medic: Medic = Depends(get_current_account), medic_availability_service: MedicAvailabilityService = Depends(get_medic_availability_service)):
    return await medic_availability_service.get_all_medic_availabilities(current_medic.id)

@router.post("/create", response_model=MedicAvailabilityOutSchema)
async def add_medic_availability_for_medic(medic_availability_payoad: MedicAvailabilityCreateSchema, current_medic: Medic = Depends(get_current_account), medic_availability_service: MedicAvailabilityService = Depends(get_medic_availability_service)):
    return await medic_availability_service.create_availability(current_medic.id, medic_availability_payoad)

@router.delete("/{medic_availability_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_availability_for_medic(medic_availability_id: int, current_medic: Medic = Depends(get_current_account), medic_availability_service: MedicAvailabilityService = Depends(get_medic_availability_service)):
    await medic_availability_service.delete_medic_availability(medic_availability_id)
    return