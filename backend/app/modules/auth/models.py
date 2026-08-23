from datetime import datetime
from typing import Annotated
from beanie import Document, Indexed, Link
from pydantic import EmailStr, Field


class User(Document):
    name: str = Field(min_length=2, max_length=100)
    email: Annotated[EmailStr, Indexed(unique=True)]
    password_hash: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "users"
