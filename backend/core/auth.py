import os
from fastapi.security import OAuth2PasswordBearer
from datetime import datetime, timedelta, timezone
from jose import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

ph = PasswordHasher()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def verify_password(plain_password, hashed_password):
    try:
        return ph.verify(hashed_password, plain_password)
    except VerifyMismatchError:
        return False
    
def create_access_token(data: dict):
    data_to_encode = data.copy()
    if "sub" in data_to_encode:
        data_to_encode["sub"] = str(data_to_encode["sub"])
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    data_to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(data_to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt
