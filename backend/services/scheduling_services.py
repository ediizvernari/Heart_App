from datetime import date, datetime, time, timedelta
from typing import List, Optional
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.sql_models import User
from backend.schemas.scheduling_schemas import TimeSlotSchema
from backend.services.medic_availability_services import get_decrypted_medic_availabilities
from backend.services.medical_service import get_decrypted_medical_service_by_id

def _parse_hhmm_to_time(s: str) -> time:
    h, m = map(int, s.split(":"))
    return time(hour=h, minute=m)

def _format_hhmm(t: time) -> str:
    return f"{t.hour:02d}:{t.minute:02d}"

async def _get_base_windows(
    db: AsyncSession,
    medic_id: int,
    target_date: date
) -> List[tuple[time, time]]:
    print(f"[DEBUG] _get_base_windows: medic_id={medic_id}, date={target_date}")
    weekday = target_date.weekday()
    print(f"[DEBUG]   looking for availabilities on weekday={weekday}")
    base_windows: List[tuple[time, time]] = []

    availabilities = await get_decrypted_medic_availabilities(db, medic_id)
    print(f"[DEBUG]   decrypted availabilities count={len(availabilities)}")
    for avail in availabilities:
        print(f"[DEBUG]     avail: weekday={avail.weekday}, start={avail.start_time}, end={avail.end_time}")
        if avail.weekday == weekday:
            start = _parse_hhmm_to_time(avail.start_time)
            end   = _parse_hhmm_to_time(avail.end_time)
            if start < end:
                base_windows.append((start, end))
    print(f"[DEBUG]   base_windows: {[(str(s), str(e)) for s,e in base_windows]}")
    return sorted(base_windows)

async def _get_busy_windows(
    db: AsyncSession,
    medic_id: int,
    target_date: date
) -> List[tuple[time, time]]:
    print(f"[DEBUG] _get_busy_windows: medic_id={medic_id}, date={target_date}")
    from backend.services.appointment_services import get_decrypted_medic_appointments

    busy_slots: List[tuple[time, time]] = []
    appointments = await get_decrypted_medic_appointments(db, medic_id)
    print(f"[DEBUG]   decrypted appointments count={len(appointments)}")
    for appt in appointments:
        start_time = datetime.strptime(appt.appointment_start, "%H:%M").time()
        end_time   = datetime.strptime(appt.appointment_end, "%H:%M").time()

        start_dt = datetime.combine(target_date, start_time)
        end_dt   = datetime.combine(target_date, end_time)
        print(f"[DEBUG]     appt: start={start_dt}, end={end_dt}")
        if start_dt.date() == target_date and start_dt.time() < end_dt.time():
            busy_slots.append((start_dt.time(), end_dt.time()))
    print(f"[DEBUG]   busy_slots: {[(str(s), str(e)) for s,e in busy_slots]}")
    return sorted(busy_slots)

def _create_free_spans(
    base_windows: List[tuple[time, time]],
    busy_windows: List[tuple[time, time]]
) -> List[tuple[time, time]]:
    print(f"[DEBUG] _create_free_spans: base={base_windows}, busy={busy_windows}")
    free_spans: List[tuple[time, time]] = []

    for win_start, win_end in base_windows:
        cursor = win_start
        overlaps = [
            (b_start, b_end)
            for b_start, b_end in busy_windows
            if b_start < win_end and b_end > win_start
        ]
        overlaps.sort(key=lambda x: x[0])
        for b_start, b_end in overlaps:
            if cursor < b_start:
                free_spans.append((cursor, b_start))
            cursor = max(cursor, b_end)
        if cursor < win_end:
            free_spans.append((cursor, win_end))

    print(f"[DEBUG]   free_spans: {[(str(s), str(e)) for s,e in free_spans]}")
    return free_spans

def _split_into_slots(
    spans: List[tuple[time, time]],
    target_date: date,
    slot_minute_duration: int
) -> List[TimeSlotSchema]:
    print(f"[DEBUG] _split_into_slots: spans={spans}, slot_min={slot_minute_duration}")
    slots: List[TimeSlotSchema] = []
    step = timedelta(minutes=slot_minute_duration)

    for start, end in spans:
        current = datetime.combine(target_date, start)
        limit   = datetime.combine(target_date, end)
        while current + step <= limit:
            t0 = current.time()
            t1 = (current + step).time()
            slots.append(TimeSlotSchema(
                start=_format_hhmm(t0),
                end=_format_hhmm(t1)
            ))
            current += step

    print(f"[DEBUG]   final slots: {[{'start': slot.start, 'end': slot.end} for slot in slots]}")
    return slots

async def get_free_time_slots_for_a_day(
    db: AsyncSession,
    medic_id: int,
    target_date: date,
    slot_minute_duration: int
) -> List[TimeSlotSchema]:
    print(f"[DEBUG] get_free_time_slots_for_a_day: medic_id={medic_id}, date={target_date}, duration={slot_minute_duration}")
    base   = await _get_base_windows(db, medic_id, target_date)
    busy   = await _get_busy_windows(db, medic_id, target_date)
    spans  = _create_free_spans(base, busy)
    return _split_into_slots(spans, target_date, slot_minute_duration)

async def get_current_user_free_time_slots(
    db: AsyncSession,
    current_user: User,
    target_date: date,
    medical_service_id: Optional[int] = None
) -> List[TimeSlotSchema]:
    print(f"[DEBUG] get_current_user_free_time_slots: user={current_user.id}, date={target_date}, svc_id={medical_service_id}")
    if not current_user.medic_id:
        raise HTTPException(status_code=403, detail="You have no assigned medic")

    duration = 30
    if medical_service_id is not None:
        service = await get_decrypted_medical_service_by_id(db, medical_service_id)
        print(f"[DEBUG]   fetched service: {service}")
        if not service or service.medic_id != current_user.medic_id:
            raise HTTPException(status_code=404, detail="Medical service not found")
        duration = service.duration_minutes

    return await get_free_time_slots_for_a_day(
        db,
        current_user.medic_id,
        target_date,
        duration
    )
