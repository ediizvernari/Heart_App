import base64
from datetime import date
import os
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

from backend import sql_models

AES_KEY = os.getenv("AES_KEY")
aes_key = base64.b64decode(AES_KEY)

def encrypt_data(data: str) -> str:
    iv = os.urandom(12)
    cipher = Cipher(algorithms.AES(aes_key), modes.GCM(iv))
    encryptor = cipher.encryptor()
    encrypted = encryptor.update(data.encode()) + encryptor.finalize()
    encrypted_data = iv + encryptor.tag + encrypted
    return base64.b64encode(encrypted_data).decode()


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
    
def decrypt_health_data_fields_for_user(encrypted_user_health_data: dict) -> dict:
    decrypted_user_health_data = {}
    for key, value in encrypted_user_health_data.items():
        try:
            decrypted_user_health_data[key] = decrypt_data(value)
        except Exception as e:
            print(f"[ERROR] Decryption failed for field {key}: {e}")
            decrypted_user_health_data[key] = "[DECRYPTION ERROR]"
    
    return decrypted_user_health_data

def decrypt_health_data_fields_for_user_prediction(encrypted_data: sql_models.UserHealthData) -> dict:
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
