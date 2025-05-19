from pydantic import BaseModel

class TokenSchema(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str

class MessageSchema(BaseModel):
    message: str

class LoginSchema(BaseModel):
    email: str
    password: str 
