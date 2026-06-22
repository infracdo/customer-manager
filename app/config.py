"""
RQ Worker Configuration
"""
from pydantic_settings import BaseSettings
from typing import Optional
import os


class Settings(BaseSettings):
    """Worker settings"""
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # Apollo Device Provisioner API
    APOLLO_PROVISIONER_URL: str = "http://localhost:8000/api/v1"
    APOLLO_PROVISIONER_TIMEOUT: int = 30
    
    # Gotify Notifications (optional)
    GOTIFY_URL: Optional[str] = None
    GOTIFY_CLIENT_KEY: Optional[str] = None
    
    # Logging
    LOG_LEVEL: str = "INFO"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
