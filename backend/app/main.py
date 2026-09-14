from contextlib import asynccontextmanager
from typing import AsyncGenerator

from beanie import init_beanie
from litestar import Litestar
from litestar.config.cors import CORSConfig
from motor.motor_asyncio import AsyncIOMotorClient

from app.config import settings
from app.modules.auth.controllers import AuthController
from app.modules.auth.models import User

cors_config = CORSConfig(
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@asynccontextmanager
async def db_lifespan(app: Litestar) -> AsyncGenerator[None, None]:
    client = AsyncIOMotorClient(settings.mongo_url)
    database = client[settings.database_name]

    await init_beanie(
        database=database,
        document_models=[User],
    )

    yield

    client.close()


app = Litestar(
    route_handlers=[AuthController],
    cors_config=cors_config,
    lifespan=[db_lifespan],
)