import base64
import os
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

AES_KEY = os.getenv("AES_KEY")
aes_key = base64.b64decode(AES_KEY)

def encrypt_data(data: str) -> str:
    iv = os.urandom(12)
    cipher = Cipher(algorithms.AES(aes_key), modes.GCM(iv))  # AES-GCM mode with generated IV
    encryptor = cipher.encryptor()
    encrypted = encryptor.update(data.encode()) + encryptor.finalize()
    encrypted_data = iv + encryptor.tag + encrypted # Concatenate IV, tag, and encrypted data
    return base64.b64encode(encrypted_data).decode()


def decrypt_data(encrypted_data_b64: str) -> str:
    encrypted_data = base64.b64decode(encrypted_data_b64)  # Decode the base64-encoded data
    iv = encrypted_data[:12]
    tag = encrypted_data[12:28]
    cipher = Cipher(algorithms.AES(aes_key), modes.GCM(iv, tag))
    decryptor = cipher.decryptor()
    decrypted = decryptor.update(encrypted_data[28:]) + decryptor.finalize()
    return decrypted.decode()