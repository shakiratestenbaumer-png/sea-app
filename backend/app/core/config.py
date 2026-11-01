from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Swiss Energy Assistant"
    app_env: str = "development"
    debug: bool = True
    secret_key: str = "change-me-to-a-random-secret-key-in-production"

    # Database
    database_url: str = "postgresql+asyncpg://sea_user:sea_password@localhost:5432/sea_db"

    # Redis
    redis_url: str = "redis://localhost:6379/0"

    # JWT Auth
    jwt_secret_key: str = "change-me-jwt-secret"
    jwt_algorithm: str = "HS256"
    jwt_expiration_minutes: int = 1440

    # Provider APIs
    ckw_api_base_url: str = "https://e-ckw-public-data.de-c1.eu1.cloudhub.io/api/v1"
    ckw_api_key: str = ""
    groupe_e_api_base_url: str = "https://api.tariffs.groupe-e.ch/v2"
    groupe_e_api_key: str = ""

    # Push notifications
    fcm_server_key: str = ""
    fcm_project_id: str = ""

    # Monitoring
    sentry_dsn: str = ""

    # Timezone
    default_timezone: str = "Europe/Zurich"

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8", "extra": "ignore"}


settings = Settings()
