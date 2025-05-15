from fastapi import HTTPException
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.crud.medical_service import create_medical_service_entity, get_all_encrypted_medical_service_types, get_all_encrypted_medical_services_for_medic, get_encrypted_medical_service_by_id, get_encrypted_medical_service_type_by_id, update_medical_service
from backend.database.sql_models import Medic, MedicalService, MedicalServiceType
from backend.schemas.medical_service_schemas import MedicalServiceOutSchema, MedicalServiceSchema, MedicalServiceTypeOutSchema, MedicalServiceTypeSchema, MedicalServiceUpdateSchema
from ..utils.encryption_utils import decrypt_data, decrypt_fields, encrypt_data, encrypt_fields


#Medical Service Type functions

async def get_all_decrypted_medical_service_types(db: AsyncSession) -> list[MedicalServiceTypeOutSchema]:
    encrypted_medical_services_types = await get_all_encrypted_medical_service_types(db)
    print(f"[INFO] Fetched {len(encrypted_medical_services_types)} encrypted medical service types")

    decrypyed_medical_services_types = []

    for medical_service_type in encrypted_medical_services_types:
        print(f"[DEBUG] Encrypted name (ID {medical_service_type.id}): {medical_service_type.name}")

        decrypted_medical_service_type_name = decrypt_data(medical_service_type.name)
        print(f"[DEBUG] Decrypted name: {decrypted_medical_service_type_name}")

        decrypyed_medical_services_types.append(
            MedicalServiceTypeOutSchema(
                id=medical_service_type.id,
                name=decrypted_medical_service_type_name
            )
        )

    print(f"[INFO] Decrypted medical service types: {[m.name for m in decrypyed_medical_services_types]}")
    return decrypyed_medical_services_types


async def create_medical_service_type(medical_service: MedicalServiceTypeSchema, db: AsyncSession) -> MedicalServiceTypeOutSchema:
    encrypted_name = encrypt_data(medical_service.name)

    existing = await db.execute(
        select(MedicalServiceType).where(MedicalServiceType.name == encrypted_name)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Service type already exists")

    db_medical_service = MedicalServiceType(
        name=encrypted_name
    )
    db.add(db_medical_service)
    await db.commit()
    await db.refresh(db_medical_service)

    #TODO: Check this in the end if it works
    return db_medical_service.id

#TODO: See if I need a get medical service type by name function    

async def get_decrypted_medical_service_type_by_id(db: AsyncSession, medical_service_type_id: int) -> MedicalServiceTypeOutSchema | None:
    encrypted_medical_service_type = await get_encrypted_medical_service_type_by_id(db, medical_service_type_id)

    if not encrypted_medical_service_type:
        raise HTTPException(status_code=404, detail="Medical service type not found")

    decrypted_medical_service_type_name = decrypt_data(encrypted_medical_service_type.name)

    return MedicalServiceTypeOutSchema(
        id=encrypted_medical_service_type.id,
        name=decrypted_medical_service_type_name
    )

#Medical Service functions

async def get_all_decrypted_medical_services_for_medic(
    db: AsyncSession,
    medic_id: int
) -> list[MedicalServiceOutSchema]:
    encrypted_services = await get_all_encrypted_medical_services_for_medic(db, medic_id)

    decrypted_services: list[MedicalServiceOutSchema] = []

    for svc in encrypted_services:
        decrypted_fields = decrypt_fields(
            svc,
            ["name", "price", "duration_minutes"]
        )
        name = decrypted_fields["name"]
        price_str = decrypted_fields["price"]
        duration_str = decrypted_fields["duration_minutes"]

        price = int(price_str)
        duration = int(duration_str)

        decrypted_services.append(
            MedicalServiceOutSchema(
                id=svc.id,
                medic_id=svc.medic_id,
                medical_service_type_id=svc.medical_service_type_id,
                name=name,
                price=price,
                duration_minutes=duration
            )
        )

    return decrypted_services


async def create_medical_service(
    db: AsyncSession,
    current_medic: Medic,
    medical_service: MedicalServiceSchema,
) -> MedicalServiceOutSchema:
    encrypted_data = encrypt_fields(
        medical_service,
        ["name", "price", "duration_minutes"]
    )

    new_service: MedicalService = await create_medical_service_entity(
        db,
        medic_id=current_medic.id,
        medical_service_type_id=medical_service.medical_service_type_id,
        **encrypted_data
    )

    decrypted = decrypt_fields(
        new_service,
        ["name", "price", "duration_minutes"]
    )

    return MedicalServiceOutSchema(
        id=new_service.id,
        medic_id=new_service.medic_id,
        medical_service_type_id=new_service.medical_service_type_id,
        name=decrypted["name"],
        price=int(decrypted["price"]),
        duration_minutes=int(decrypted["duration_minutes"])
    )

async def get_decrypted_medical_service_by_id(db: AsyncSession, medical_service_id: int):
    encrypted_medical_service = await get_encrypted_medical_service_by_id(db, medical_service_id)

    if not encrypted_medical_service:
        raise HTTPException(status_code=404, detail="Medical service not found")

    decrypted_fields = decrypt_fields(encrypted_medical_service, ["name", "price", "duration_minutes"])

    return MedicalServiceOutSchema(
        id=encrypted_medical_service.id,
        medic_id=encrypted_medical_service.medic_id,
        medical_service_type_id=encrypted_medical_service.medical_service_type_id,
        **decrypted_fields
    )

async def update_medical_service_for_medic(db: AsyncSession, medic_id: int, medical_service_id: int, updated_medical_service: MedicalServiceUpdateSchema):
    encrypted_medical_service = await get_encrypted_medical_service_by_id(db, medical_service_id)

    if not encrypted_medical_service or encrypted_medical_service.medic_id != medic_id:
        raise HTTPException(status_code=404, detail="Medical service not found")
    
    updates = updated_medical_service.model_dump(exclude_unset=True)
    if(updates):
        encrypted_fields = encrypt_fields(updates, list(updates.keys()))
        await update_medical_service(db, medical_service_id, encrypted_fields)
  
    return await get_decrypted_medical_service_by_id(db, medical_service_id)

async def delete_medical_service_for_medic(db: AsyncSession, medic_id: int, medical_service_id: int):
    encrypted_medical_service = await get_encrypted_medical_service_by_id(db, medical_service_id)

    if not encrypted_medical_service or encrypted_medical_service.medic_id != medic_id:
        raise HTTPException(status_code=404, detail="Medical service not found")
    
    await db.delete(encrypted_medical_service)
    await db.commit()
    return {"message": "Medical service deleted successfully"}
