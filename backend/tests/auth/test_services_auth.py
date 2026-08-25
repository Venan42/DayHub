from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

import pytest
from litestar.exceptions import HTTPException

from app.modules.auth.schemas import UserLoginDTO, UserRegisterDTO
from app.modules.auth.services import AuthService


def make_fake_user(
    email: str = "user@example.com",
    password_hash: str = "hashed_password_123",
):
    fake_user = AsyncMock()
    fake_user.id = "507f1f77bcf86cd799439011"
    fake_user.name = "John Doe"
    fake_user.email = email
    fake_user.password_hash = password_hash
    fake_user.created_at = datetime.now(timezone.utc)
    return fake_user


@pytest.mark.asyncio
@patch("app.modules.auth.services.create_access_token", return_value="fake.jwt.token")
@patch("app.modules.auth.services.hash_password", return_value="hashed_password_123")
@patch("app.modules.auth.services.User")
async def test_register_success_returns_token_and_user(
    mock_user_cls, mock_hash_password, mock_create_token
):
    mock_user_cls.find_one = AsyncMock(return_value=None)

    fake_user = make_fake_user()
    mock_user_cls.return_value = fake_user
    fake_user.insert = AsyncMock(return_value=None)

    data = UserRegisterDTO(
        name="John Doe", email="user@example.com", password="secret123"
    )

    result = await AuthService.register(data)

    mock_user_cls.find_one.assert_awaited_once()
    fake_user.insert.assert_awaited_once()
    mock_create_token.assert_called_once_with(subject=str(fake_user.id))
    assert result.access_token == "fake.jwt.token"
    assert result.token_type == "bearer"
    assert result.user.email == "user@example.com"


@pytest.mark.asyncio
@patch("app.modules.auth.services.User")
async def test_register_with_existing_email_raises_400(mock_user_cls):
    """Registrar com e-mail já existente deve levantar HTTPException 400."""
    mock_user_cls.find_one = AsyncMock(return_value=make_fake_user())

    data = UserRegisterDTO(
        name="Jane Doe", email="user@example.com", password="secret123"
    )

    with pytest.raises(HTTPException) as exc_info:
        await AuthService.register(data)

    assert exc_info.value.status_code == 400
    assert "already registered" in str(exc_info.value.detail)


@pytest.mark.asyncio
@patch("app.modules.auth.services.create_access_token", return_value="fake.jwt.token")
@patch("app.modules.auth.services.verify_password", return_value=True)
@patch("app.modules.auth.services.User")
async def test_login_success_returns_token(
    mock_user_cls, mock_verify_password, mock_create_token
):
    fake_user = make_fake_user()
    mock_user_cls.find_one = AsyncMock(return_value=fake_user)

    data = UserLoginDTO(email="user@example.com", password="secret123")

    result = await AuthService.login(data)

    mock_verify_password.assert_called_once_with("secret123", fake_user.password_hash)
    mock_create_token.assert_called_once_with(subject=str(fake_user.id))
    assert result.access_token == "fake.jwt.token"
    assert result.user.email == "user@example.com"


@pytest.mark.asyncio
@patch("app.modules.auth.services.verify_password", return_value=False)
@patch("app.modules.auth.services.User")
async def test_login_with_wrong_password_raises_401(
    mock_user_cls, mock_verify_password
):
    fake_user = make_fake_user()
    mock_user_cls.find_one = AsyncMock(return_value=fake_user)

    data = UserLoginDTO(email="user@example.com", password="wrong-password")

    with pytest.raises(HTTPException) as exc_info:
        await AuthService.login(data)

    assert exc_info.value.status_code == 401
    assert "Invalid credentials" in str(exc_info.value.detail)
