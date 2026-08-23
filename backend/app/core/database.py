from contextlib import asynccontextmanager
from typing import AsyncGenerator
from beanie import init_beanie
from litestar import Litestar
from motor.motor_asyncio import AsyncIOMotorClient
import os

from app.config import settings

MONGO_URL = settings.mongo_url
DATABASE_NAME = settings.mongo_url


@asynccontextmanager
async def db_lifespan(app: Litestar) -> AsyncGenerator[None, None]:
    client = AsyncIOMotorClient(MONGO_URL)
    database = client[DATABASE_NAME]

    await init_beanie(
        database=database, #type: ignore
        document_models=[],
    )

    yield

    client.close()