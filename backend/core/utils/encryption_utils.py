import base64
import hashlib
import hmac
import unicodedata
import os
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

AES_KEY = os.getenv("AES_KEY")
if not AES_KEY:
    raise RuntimeError("Missing AES_KEY_BASE environment variable")
try:
    aes_key = base64.b64decode(AES_KEY)
except Exception:
    raise RuntimeError("AES_KEY_BASE is not valid Base64")

LOOKUP_KEY_B64 = os.getenv("LOOKUP_KEY_BASE64")
if not LOOKUP_KEY_B64:
    raise RuntimeError("Missing LOOKUP_KEY_BASE64 environment variable")
try:
    lookup_key = base64.b64decode(LOOKUP_KEY_B64)
except Exception:
    raise RuntimeError("LOOKUP_KEY_BASE64 is not valid Base64")
if len(lookup_key) != 32:
    raise RuntimeError("LOOKUP_KEY_BASE64 must decode to 32 bytes (256 bits)")

def normalize_text(text: str) -> str:
    normalized_text = unicodedata.normalize("NFKC", text)
    return normalized_text.strip().casefold()

def make_lookup_hash(plaintext: str) -> str:
    canon = normalize_text(plaintext)
    return hmac.new(lookup_key, canon.encode("utf-8"), hashlib.sha256).hexdigest()

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
        print(f"[ERROR] Decryption failed: {e}")
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
