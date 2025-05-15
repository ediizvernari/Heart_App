import base64
from datetime import date
import os
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

from ..database.sql_models import UserHealthData, Medic, City, Country
from ..schemas.medic_schemas import MedicOut

ENCRYPTED_FIELDS = {
    "birth_date",
    "height",
    "weight",
    "cholesterol_level",
    "ap_hi",
    "ap_lo",
}

ENCRYPTED_MEDIC_FIELDS = {
    "first_name",
    "last_name",
    "street_address",
    "city",
    "country",
}

AES_KEY = os.getenv("AES_KEY")
aes_key = base64.b64decode(AES_KEY)

def encrypt_data(data: str) -> str:
    iv = os.urandom(12)
    cipher = Cipher(algorithms.AES(aes_key), modes.GCM(iv))
    encryptor = cipher.encryptor()
    encrypted = encryptor.update(data.encode()) + encryptor.finalize()
    encrypted_data = iv + encryptor.tag + encrypted
    return base64.b64encode(encrypted_data).decode()

def encrypt_fields(obj: object | dict, fields: list[str]) -> dict:
    encrypted = {}
    for field in fields:
        value = obj[field] if isinstance(obj, dict) else getattr(obj, field, None)
        if value is not None:
            try:
                encrypted[field] = encrypt_data(str(value))
            except Exception as e:
                print(f"[ERROR] Encryption failed for '{field}': {e}")
                encrypted[field] = "[ENCRYPTION ERROR]"
        else:
            encrypted[field] = None
    return encrypted

def decrypt_data(encrypted_data_b64: str) -> str:
    try:
        encrypted_data = base64.b64decode(encrypted_data_b64)

        iv = encrypted_data[:12]
        tag = encrypted_data[12:28]
        ciphertext = encrypted_data[28:]

        cipher = Cipher(algorithms.AES(aes_key), modes.GCM(iv, tag))
        decryptor = cipher.decryptor()
        decrypted = decryptor.update(ciphertext) + decryptor.finalize()
        return decrypted.decode()
    except Exception as e:
        print(f"Decryption failed: {e}")
        return "[DECRYPTION ERROR]"

def decrypt_fields(obj, fields: list[str]) -> dict:
    decrypted = {}
    for field in fields:
        try:
            value = getattr(obj, field)
            decrypted[field] = decrypt_data(value) if value else None
        except Exception as e:
            print(f"[ERROR] Decryption failed for field '{field}': {e}")
            decrypted[field] = "[DECRYPTION ERROR]"
    return decrypted

#TODO: Use the decrypt_fields function for refactoring other functions across the project
def decrypt_health_data_fields_for_user(encrypted_user_health_data: dict) -> dict:
    decrypted_user_health_data = {}
    
    for key, value in encrypted_user_health_data.items():
        if key in ENCRYPTED_FIELDS and isinstance(value, (str, bytes)):
            try:
                decrypted_user_health_data[key] = decrypt_data(value)
                print(f"[DEBUG] Decrypted {key}: {decrypted_user_health_data[key]}")
            except Exception as e:
                print(f"[ERROR] Decryption failed for field '{key}': {e}")
                decrypted_user_health_data[key] = "[DECRYPTION ERROR]"
        else:
            decrypted_user_health_data[key] = value
            print(f"[DEBUG] Skipped decryption for field '{key}', kept value: {value}")
    
    return decrypted_user_health_data

def decrypt_health_data_fields_for_user_prediction(encrypted_data: UserHealthData) -> dict:
    data = dict(encrypted_data.__dict__)
    data.pop('_sa_instance_state', None)

    decrypted = decrypt_health_data_fields_for_user(data)

    try:
        birth_date = date.fromisoformat(decrypted["birth_date"])
        height = float(decrypted["height"])
        weight = float(decrypted["weight"])
        cholesterol_level = int(decrypted["cholesterol_level"])
        ap_hi = int(decrypted["ap_hi"])
        ap_lo = int(decrypted["ap_lo"])

        return {
            "birth_date": birth_date,
            "height": height,
            "weight": weight,
            "cholesterol_level": cholesterol_level,
            "ap_hi": ap_hi,
            "ap_lo": ap_lo,
        }

    except Exception as e:
        print(f"[ERROR] Failed to parse decrypted data: {e}")
        raise ValueError("Invalid decrypted health data format")
