from typing import Annotated
from litestar import Controller, get, post
from litestar.di import Provide
from litestar.params import Dependency
from litestar.status_codes import HTTP_200_OK, HTTP_201_CREATED

from app.modules.auth.dependencies import provide_current_user
from app.modules.auth.models import User
from app.modules.auth.schemas import (
    TokenDTO,
    UserLoginDTO,
    UserRegisterDTO,
    UserResponseDTO,
)
from app.modules.auth.services import AuthService


class AuthController(Controller):
    path = "/auth"
    dependencies = {"current_user": Provide(provide_current_user, sync_to_thread=False)}

    @post(path="/register", status_code=HTTP_201_CREATED)
    async def register(self, data: UserRegisterDTO) -> TokenDTO:
        return await AuthService.register(data)

    @post(path="/login", status_code=HTTP_200_OK)
    async def login(self, data: UserLoginDTO) -> TokenDTO:
        return await AuthService.login(data)

    @get(path="/me", status_code=HTTP_200_OK)
    async def get_me(
        self, current_user: Annotated[User, Dependency(skip_validation=True)]
    ) -> UserResponseDTO:
        return UserResponseDTO(
            id=str(current_user.id),
            name=current_user.name,
            email=current_user.email,
            created_at=current_user.created_at,
        )
