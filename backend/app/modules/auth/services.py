from litestar.exceptions import HTTPException
from litestar.status_codes import HTTP_400_BAD_REQUEST, HTTP_401_UNAUTHORIZED

from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
)
from app.modules.auth.models import User
from app.modules.auth.schemas import (
    TokenDTO,
    UserLoginDTO,
    UserRegisterDTO,
    UserResponseDTO,
)


class AuthService:
    @staticmethod
    async def register(data: UserRegisterDTO) -> TokenDTO:
        existing_user = await User.find_one(User.email == data.email)
        if existing_user:
            raise HTTPException(
                status_code=HTTP_400_BAD_REQUEST, detail="Email already registered"
            )

        user = User(
            name=data.name,
            email=data.email,
            password_hash=hash_password(data.password),
        )
        await user.insert()

        access_token = create_access_token(subject=str(user.id))

        user_response = UserResponseDTO(
            id=str(user.id),
            name=user.name,
            email=user.email,
            created_at=user.created_at,
        )

        return TokenDTO(
            access_token=access_token,
            token_type="bearer",
            user=user_response,
        )

    @staticmethod
    async def login(data: UserLoginDTO) -> TokenDTO:
        user = await User.find_one(User.email == data.email)
        if not user or not verify_password(data.password, user.password_hash):
            raise HTTPException(
                status_code=HTTP_401_UNAUTHORIZED, detail="Invalid credentials"
            )

        access_token = create_access_token(subject=str(user.id))

        user_response = UserResponseDTO(
            id=str(user.id),
            name=user.name,
            email=user.email,
            created_at=user.created_at,
        )

        return TokenDTO(
            access_token=access_token,
            token_type="bearer",
            user=user_response,
        )
