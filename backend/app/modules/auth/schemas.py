from datetime import datetime
from pydantic import BaseModel, EmailStr, Field


class UserRegisterDTO(BaseModel):
    name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)


class UserLoginDTO(BaseModel):
    email: EmailStr
    password: str


class UserResponseDTO(BaseModel):
    id: str
    name: str
    email: EmailStr
    created_at: datetime


class TokenDTO(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponseDTO
