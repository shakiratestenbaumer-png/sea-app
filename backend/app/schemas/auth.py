from pydantic import BaseModel, EmailStr


class AuthBootstrap(BaseModel):
    email: str
    locale: str = "de-CH"


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    email: str
