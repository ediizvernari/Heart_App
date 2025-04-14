from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, ExpiredSignatureError, jwt
from sqlalchemy.ext.asyncio import AsyncSession
from ..database.connection import get_db
from ..crud.user import get_user_by_id, get_user_by_email
from ..crud.medic import get_medic_by_id, get_medic_by_email
from ..core.auth import create_access_token, verify_password
from ..core.auth import SECRET_KEY, ALGORITHM

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

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
        account = await get_user_by_id(db, user_id=account_id)
    elif role == 'medic':
        account = await get_medic_by_id(db, medic_id=account_id)
    else:
        raise credentials_exception
    
    if account is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Account not found",
        )
    
    return account

#In functia de loginm verificam daca userul e user sau medic, in functie de asta ii dam tokenul corespunzator
async def login_account(email: str, password: str, db: AsyncSession):
    found_user = await get_user_by_email(db, email=email)
    if found_user and verify_password(password, found_user.password):
        token = create_access_token(data={"sub": found_user.id, "role": "user"})
        return {"access_token": token, "token_type": "bearer", "role": "user"}
    
    found_medic = await get_medic_by_email(db, email=email)
    if found_medic and verify_password(password, found_medic.password):
        token = create_access_token(data={"sub": found_medic.id, "role": "medic"})
        return {"access_token": token, "token_type": "bearer", "role": "medic"}
    
    raise HTTPException(
        status_code=400,
        detail="Incorrect email or password",
        headers={"WWW-Authenticate": "Bearer"},
    )
    