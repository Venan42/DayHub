from litestar.exceptions import HTTPException, NotFoundException
from litestar.connection import ASGIConnection
from litestar.status_codes import HTTP_401_UNAUTHORIZED

from app.core.security import decode_access_token
from app.modules.auth.models import User


async def provide_current_user(request: ASGIConnection) -> User:
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(
            status_code=HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing authorization header",
        )

    token = auth_header.split(" ")[1]
    payload = decode_access_token(token)
    if not payload or "sub" not in payload:
        raise HTTPException(
            status_code=HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    user_id = str(payload["sub"])

    try:
        user = await User.get(user_id)
    except Exception:
        raise HTTPException(
            status_code=HTTP_401_UNAUTHORIZED,
            detail="Could not retrieve user context",
        )

    if not user:
        raise NotFoundException(detail="User not found")

    return user
