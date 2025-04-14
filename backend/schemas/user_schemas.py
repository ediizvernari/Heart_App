from pydantic import BaseModel

class Login(BaseModel):
    email: str
    password: str

#Clasa asta mosteneste clasa UserBase si are in plus un password
class UserCreateSchema(BaseModel):
    first_name: str
    last_name: str
    email: str
    password: str

#TODO: Add the rest of the fields at the data insertion later
class UserSchema(UserCreateSchema):
    id: int

    model_config = {
        "from_attributes": True
    }
    