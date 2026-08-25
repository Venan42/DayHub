from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from litestar import Litestar
from litestar.testing import TestClient

from app.modules.auth.controllers import AuthController
from app.modules.auth.schemas import TokenDTO, UserResponseDTO


@pytest.fixture
def make_token_dto():
    def _factory(email: str = "user@example.com") -> TokenDTO:
        return TokenDTO(
            access_token="fake.jwt.token",
            token_type="bearer",
            user=UserResponseDTO(
                id="507f1f77bcf86cd799439011",
                name="John Doe",
                email=email,
                created_at=datetime.now(timezone.utc),
            ),
        )

    return _factory


@pytest.fixture
def client():
    app = Litestar(route_handlers=[AuthController])
    with TestClient(app=app) as test_client:
        yield test_client


@patch("app.modules.auth.controllers.AuthService.register", new_callable=AsyncMock)
def test_register_endpoint_returns_201_with_token(
    mock_register, client, make_token_dto
):
    mock_register.return_value = make_token_dto()

    response = client.post(
        "/auth/register",
        json={"name": "John Doe", "email": "user@example.com", "password": "secret123"},
    )

    assert response.status_code == 201
    assert response.json()["access_token"] == "fake.jwt.token"


@patch("app.modules.auth.controllers.AuthService.register", new_callable=AsyncMock)
def test_register_endpoint_with_invalid_payload_returns_400(mock_register, client):
    response = client.post(
        "/auth/register",
        json={"name": "John Doe", "email": "not-an-email", "password": "secret123"},
    )

    assert response.status_code == 400


@patch("app.modules.auth.controllers.AuthService.login", new_callable=AsyncMock)
def test_login_endpoint_returns_200_with_token(mock_login, client, make_token_dto):
    mock_login.return_value = make_token_dto()

    response = client.post(
        "/auth/login",
        json={"email": "user@example.com", "password": "secret123"},
    )

    assert response.status_code == 200


@patch("app.modules.auth.dependencies.User.get", new_callable=AsyncMock)
@patch("app.modules.auth.dependencies.decode_access_token")
def test_get_me_endpoint_returns_current_user(mock_decode_token, mock_user_get, client):
    fake_user = MagicMock()
    fake_user.id = "507f1f77bcf86cd799439011"
    fake_user.name = "John Doe"
    fake_user.email = "user@example.com"
    fake_user.created_at = datetime.now(timezone.utc)

    mock_decode_token.return_value = {"sub": "507f1f77bcf86cd799439011"}
    mock_user_get.return_value = fake_user

    response = client.get(
        "/auth/me",
        headers={"Authorization": "Bearer valid.jwt.token"},
    )

    assert response.status_code == 200
    assert response.json()["email"] == "user@example.com"


def test_get_me_endpoint_unauthenticated(client):
    response = client.get("/auth/me")
    assert response.status_code == 401
