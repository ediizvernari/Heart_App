from datetime import date, datetime, time, timedelta
from typing import TYPE_CHECKING, List, Optional, Tuple
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException

from backend.database.sql_models import User
from backend.features.appointments.core.appointment_repository import AppointmentRepository
from backend.features.medical_service.medical_service_service import MedicalServiceService
from backend.features.appointments.medic_availability.medic_availability_service import MedicAvailabilityService
from backend.features.appointments.scheduling.scheduling_schemas import TimeSlotSchema
from backend.utils.encryption_utils import decrypt_fields

if TYPE_CHECKING:
    from backend.features.appointments.core.appointment_service import AppointmentService

def _parse_hhmm_to_time(s: str) -> time:
    h, m = map(int, s.split(':'))
    return time(hour=h, minute=m)


def _format_hhmm(t: time) -> str:
    return f"{t.hour:02d}:{t.minute:02d}"


def _split_into_slots(spans: List[Tuple[time, time]], target_date: date, slot_minute_duration: int) -> List[TimeSlotSchema]:
    slots: List[TimeSlotSchema] = []
    step = timedelta(minutes=slot_minute_duration)
    
    for start, end in spans:
        current = datetime.combine(target_date, start)
        limit = datetime.combine(target_date, end)
        while current + step <= limit:
            t0 = current.time()
            t1 = (current + step).time()
            slots.append(TimeSlotSchema(start=_format_hhmm(t0), end=_format_hhmm(t1)))
            current += step
    return slots


class SchedulingService:
    def __init__(self, db: AsyncSession, appointment_repo: AppointmentRepository, medical_service: MedicalServiceService, medic_availability_service: MedicAvailabilityService):
        self.db = db
        self._appointment_repo = appointment_repo
        self._medical_service = medical_service
        self._medic_availability_service = medic_availability_service

    async def _get_base_windows(self, medic_id: int, target_date: date) -> List[Tuple[time, time]]:
        weekday = target_date.weekday()
        base_windows: List[Tuple[time, time]] = []
        availabilities = await self._medic_availability_service.get_all_medic_availabilities(medic_id)
        
        for avail in availabilities:
            if avail.weekday == weekday:
                start = _parse_hhmm_to_time(avail.start_time)
                end = _parse_hhmm_to_time(avail.end_time)
                if start < end:
                    base_windows.append((start, end))
        return sorted(base_windows)

    async def _get_busy_windows(self, medic_id: int, target_date: date) -> List[Tuple[time, time]]: 
        busy_slots: List[Tuple[time, time]] = []
    
        encrypted_rows = await self._appointment_repo.get_medic_appointments(medic_id)
    
        for row in encrypted_rows:
            dec = decrypt_fields(row, ["appointment_start", "appointment_end"])
            
            start_dt = datetime.fromisoformat(dec["appointment_start"])
            end_dt   = datetime.fromisoformat(dec["appointment_end"])
            
            if start_dt.date() == target_date and start_dt < end_dt:
                busy_slots.append((start_dt.time(), end_dt.time()))
        
        return sorted(busy_slots)

    def _create_free_spans(self, base_windows: List[Tuple[time, time]], busy_windows: List[Tuple[time, time]]) -> List[Tuple[time, time]]:
        free_spans: List[Tuple[time, time]] = []
        
        for win_start, win_end in base_windows:
            cursor = win_start
            overlaps = [b for b in busy_windows if b[0] < win_end and b[1] > win_start]
            overlaps.sort(key=lambda x: x[0])
            for b_start, b_end in overlaps:
                if cursor < b_start:
                    free_spans.append((cursor, b_start))
                cursor = max(cursor, b_end)
            if cursor < win_end:
                free_spans.append((cursor, win_end))
        return free_spans

    async def get_free_time_slots_for_a_day(self, medic_id: int, target_date: date, slot_minute_duration: int) -> List[TimeSlotSchema]:
        base = await self._get_base_windows(medic_id, target_date)
        busy = await self._get_busy_windows(medic_id, target_date)
        spans = self._create_free_spans(base, busy)
        
        return _split_into_slots(spans, target_date, slot_minute_duration)

    async def get_current_user_free_time_slots(self, current_user: User, target_date: date, medical_service_id: Optional[int] = None) -> List[TimeSlotSchema]:
        if not current_user.medic_id:
            raise HTTPException(status_code=403, detail="You have no assigned medic")
        duration = 30
        if medical_service_id:
            svc = await self._medical_service.get_medical_service_by_id(medical_service_id)
            if svc.medic_id != current_user.medic_id:
                raise HTTPException(status_code=404, detail="Medical service not found")
            duration = svc.duration_minutes
        
        return await self.get_free_time_slots_for_a_day(current_user.medic_id, target_date, duration)