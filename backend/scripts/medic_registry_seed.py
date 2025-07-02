import logging
from sqlalchemy.ext.asyncio import AsyncSession

from backend.core.database.connection import SessionLocal
from backend.features.medics.medic_registry_repository import MedicRegistryRepository
from backend.core.utils.encryption_utils import make_lookup_hash, encrypt_data

MOCK_MEDICS = [
    { "first_name": "Maria", "last_name": "Popescu", "license_number": "CMR5663001"},
    { "first_name": "Dana", "last_name": "Cepeu", "license_number": "CMR6260590"},
    { "first_name": "Maria", "last_name": "Popescu", "license_number": "CMR5555555"},
]

async def seed_medic_registry(db: AsyncSession):
    repo = MedicRegistryRepository(db)

    count = await repo.count_medics_in_registry()
    if count > 0:
        logging.info(f"MedicRegistry already populated ({count} rows), skipping.")
        return

    for rec in MOCK_MEDICS:
        lookup = make_lookup_hash(rec["license_number"])
        encrypted_license = encrypt_data(rec["license_number"])
        encrypted_first = encrypt_data(rec["first_name"])
        encrypted_last = encrypt_data(rec["last_name"])

        await repo.create_medic_for_registry(
            first_name = encrypted_first,
            last_name = encrypted_last,
            license_number = encrypted_license,
            lookup_hash = lookup
        )