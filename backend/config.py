# backend/config.py
from dotenv import load_dotenv
import os

load_dotenv()


class Config:
    SECRET_KEY = os.getenv("SECRET_KEY")
    SQLALCHEMY_DATABASE_URI = os.getenv("SQLALCHEMY_DATABASE_URI")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    DEBUG = os.getenv("DEBUG", "False") == "True"

    # JWT settings
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
    JWT_TOKEN_LOCATION = ["cookies"]
    JWT_COOKIE_SECURE = True  # HTTPS only; overridden below
    JWT_COOKIE_SAMESITE = "Lax"  # Lax by default
    JWT_COOKIE_CSRF_PROTECT = True
    JWT_ACCESS_TOKEN_EXPIRES = 900  # 15 minutes
    JWT_REFRESH_TOKEN_EXPIRES = 2592000  # 30 days
    JWT_ACCESS_COOKIE_NAME = "access_token_cookie"
    JWT_REFRESH_COOKIE_NAME = "refresh_token_cookie"
    JWT_ACCESS_CSRF_COOKIE_NAME = "csrf_access_token"
    JWT_REFRESH_CSRF_COOKIE_NAME = "csrf_refresh_token"

    # CORS: wildcard for now
    CORS_ORIGINS = [
        "http://localhost:5173",  # Vite dev
        "http://192.168.100.8:5173",  # Your LAN IP + Vite
    ]

    # Rate limiting defaults
    RATELIMIT_DEFAULT = "200 per day;50 per hour"
    RATELIMIT_STORAGE_URI = "memory://"


class DevelopmentConfig(Config):
    FLASK_ENV = "development"
    DEBUG = True
    JWT_COOKIE_SECURE = False  # allow cookies over HTTP in dev
    JWT_COOKIE_SAMESITE = "Lax"
    CORS_ORIGINS = [
        "http://localhost:5173",  # Vite dev
        "http://192.168.100.8:5173",  # Your LAN IP + Vite
    ]  # allow all origins in dev


class ProductionConfig(Config):
    FLASK_ENV = "production"
    DEBUG = False
    JWT_COOKIE_SECURE = False  # TEMP: allow HTTP for testing
    JWT_COOKIE_SAMESITE = "Lax"  # TEMP: relax SameSite
    CORS_ORIGINS = ["*"]  # TEMP: allow all origins in prod too
