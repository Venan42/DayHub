from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    mongo_url: str
    database_name: str
    jwt_secret_key: str
    jwt_algorithm: str
    acess_token_expire_minutes: int

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )


settings = Settings()  # type: ignore[call-arg]
