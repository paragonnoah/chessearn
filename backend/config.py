from dotenv import load_dotenv
import os

load_dotenv()

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "default-secret")
    SQLALCHEMY_DATABASE_URI = os.getenv("SQLALCHEMY_DATABASE_URI", "sqlite:///app.db")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    DEBUG = os.getenv("DEBUG", "False").lower() == "true"

    # JWT Configuration
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "jwt-secret")
    JWT_TOKEN_LOCATION = ["cookies"]
    JWT_COOKIE_SAMESITE = "Lax"
    JWT_COOKIE_SECURE = False
    # JWT_COOKIE_SAMESITE = "None" #for prod
    # JWT_COOKIE_SECURE = True
    JWT_COOKIE_CSRF_PROTECT = True
    JWT_ACCESS_TOKEN_EXPIRES = 9000
    JWT_REFRESH_TOKEN_EXPIRES = 2592000
    JWT_ACCESS_COOKIE_NAME = "access_token_cookie"
    JWT_REFRESH_COOKIE_NAME = "refresh_token_cookie"
    JWT_ACCESS_CSRF_COOKIE_NAME = "csrf_access_token"
    JWT_REFRESH_CSRF_COOKIE_NAME = "csrf_refresh_token"

    # Session Security
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_SAMESITE = "Lax"

    # Rate limiting
    RATELIMIT_DEFAULT = "200 per day;50 per hour"
    RATELIMIT_STORAGE_URI = "memory://"

    # CORS Origins
    CORS_ORIGINS = [
        "https://chessearn.com",
        "https://www.chessearn.com",
        "http://192.168.100.8:3000",
    ]

  