from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.connection import SessionLocal
from backend.features.medics.medic_registry_repository import MedicRegistryRepository
from backend.utils.encryption_utils import make_lookup_hash, encrypt_data

MOCK_MEDICS = [
    { "first_name": "Ioana", "last_name": "Popescu", "license_number": "CMR5663001"},
    { "first_name": "Valentin", "last_name": "Ionescu", "license_number": "CMR6021042"},
    { "first_name": "Medic", "last_name": "Bun", "license_number": "CMR5555555"},
]

async def seed_medic_registry(db: AsyncSession):
    repo = MedicRegistryRepository(db)

    count = await repo.count_medics_in_registry()
    if count > 0:
        print(f"MedicRegistry already populated ({count} rows), skipping.")
        return

    for rec in MOCK_MEDICS:
        lookup = make_lookup_hash(rec["license_number"])
        encrypted_license = encrypt_data(rec["license_number"])
        encrypted_first   = encrypt_data(rec["first_name"])
        encrypted_last    = encrypt_data(rec["last_name"])

        await repo.create_medic_for_registry(
            first_name     = encrypted_first,
            last_name      = encrypted_last,
            license_number = encrypted_license,
            lookup_hash    = lookup
        )