import os
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from datetime import datetime, timedelta, timezone
from jose import ExpiredSignatureError, JWTError, jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
from backend import crud
from backend.database import get_db
from sqlalchemy.ext.asyncio import AsyncSession

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

async def get_current_account(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        account_id: int = payload.get("sub")
        role = payload.get("role")
        if account_id is None or role is None:
            raise credentials_exception
        account_id = int(account_id)
    except ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except JWTError:
        raise credentials_exception

    if role == 'user':
        account = await crud.get_user_by_id(db, user_id=account_id)
    elif role == 'medic':
        account = await crud.get_medic_by_id(db, medic_id=account_id)
    else:
        raise credentials_exception
    
    if account is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Account not found",
        )
    
    return account
