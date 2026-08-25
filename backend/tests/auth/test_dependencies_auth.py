from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from litestar.exceptions import HTTPException

from app.modules.auth.dependencies import provide_current_user


def make_connection(auth_header: str | None):
    connection = MagicMock()
    connection.headers = {"Authorization": auth_header} if auth_header else {}
    return connection


@pytest.mark.asyncio
@patch("app.modules.auth.dependencies.decode_access_token")
@patch("app.modules.auth.dependencies.User")
async def test_provide_current_user_with_valid_token_returns_user(
    mock_user_cls, mock_decode_token
):
    mock_decode_token.return_value = {"sub": "507f1f77bcf86cd799439011"}

    fake_user = AsyncMock()
    fake_user.id = "507f1f77bcf86cd799439011"
    mock_user_cls.get = AsyncMock(return_value=fake_user)

    connection = make_connection("Bearer valid.jwt.token")

    result = await provide_current_user(connection)

    mock_decode_token.assert_called_once_with("valid.jwt.token")
    mock_user_cls.get.assert_awaited_once_with("507f1f77bcf86cd799439011")
    assert result is fake_user


@pytest.mark.asyncio
async def test_provide_current_user_without_authorization_header_raises_401():
    connection = make_connection(None)

    with pytest.raises(HTTPException) as exc_info:
        await provide_current_user(connection)

    assert exc_info.value.status_code == 401
    assert "Invalid or missing authorization header" in str(exc_info.value.detail)
