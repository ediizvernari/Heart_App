from typing import AsyncGenerator, Union
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import ExpiredSignatureError, JWTError, jwt
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.connection import get_db
from backend.database.sql_models import Medic, User
from backend.features.users.deps import get_user_repo
from backend.features.medics.deps import get_medic_repo
from .auth_service import AuthService
from backend.features.users.user_repository import UserRepository
from backend.features.medics.medic_repository import MedicRepository
from backend.core.auth import SECRET_KEY, ALGORITHM

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_auth_service(user_repo:  UserRepository  = Depends(get_user_repo), medic_repo: MedicRepository = Depends(get_medic_repo)) -> AsyncGenerator[AuthService, None]:
    yield AuthService(user_repo, medic_repo)


async def get_current_account(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db), user_repo:  UserRepository = Depends(get_user_repo), medic_repo: MedicRepository = Depends(get_medic_repo)) -> Union[User, Medic]:

    creds_exc = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        account_id = int(payload.get("sub", 0))
        role = payload.get("role")
        if role not in ("user", "medic"):
            raise creds_exc
    except ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except (JWTError, ValueError):
        raise creds_exc

    if role == "user":
        account = await user_repo.get_user_by_id(account_id)
    else:
        account = await medic_repo.get_medic_by_id(account_id)

    if not account:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Account not found",
        )

    return account

async def get_current_account(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db),user_repo:  UserRepository  = Depends(lambda db=Depends(get_db): UserRepository(db)), medic_repo: MedicRepository = Depends(lambda db=Depends(get_db): MedicRepository(db)),):
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
            account = await user_repo.get_user_by_id(user_id=account_id)
        elif role == 'medic':
            account = await medic_repo.get_medic_by_id(medic_id=account_id)
        else:
            raise credentials_exception
        
        if account is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Account not found",
            )
        
        return account