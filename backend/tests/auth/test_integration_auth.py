import os
from typing import cast
import pytest
import pytest_asyncio
from beanie import init_beanie
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo.asynchronous.database import AsyncDatabase

from app.modules.auth.models import User
from app.modules.auth.schemas import UserLoginDTO, UserRegisterDTO
from app.modules.auth.services import AuthService

TEST_MONGO_URL = os.environ.get("TEST_MONGO_URL", "mongodb://localhost:27018")
TEST_DATABASE_NAME = os.environ.get("TEST_DATABASE_NAME","dayhub_test")


@pytest_asyncio.fixture
async def test_db():
    client = AsyncIOMotorClient(TEST_MONGO_URL)
    database = client[TEST_DATABASE_NAME]

    await init_beanie(
        database=database,
        document_models=[User],
    )

    await User.delete_all()
    yield database
    await User.delete_all()

    client.close()

@pytest.mark.asyncio
async def test_register_persists_user_in_mongodb(test_db):
    data = UserRegisterDTO(
        name="John Doe",
        email="integration@example.com",
        password="secret123",
    )

    await AuthService.register(data)

    saved_user = await User.find_one(User.email == "integration@example.com")

    assert saved_user is not None
    assert saved_user.name == "John Doe"
    assert saved_user.email == "integration@example.com"
    assert saved_user.password_hash != "secret123"


@pytest.mark.asyncio
async def test_login_reads_existing_user_from_mongodb(test_db):
    register_data = UserRegisterDTO(
        name="Jane Doe",
        email="jane@example.com",
        password="secret123",
    )
    await AuthService.register(register_data)

    login_data = UserLoginDTO(email="jane@example.com", password="secret123")
    result = await AuthService.login(login_data)

    assert result.access_token is not None
    assert result.user.email == "jane@example.com"

    users_with_email = await User.find(User.email == "jane@example.com").to_list()
    assert len(users_with_email) == 1
