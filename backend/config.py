from dotenv import load_dotenv
import os

load_dotenv()

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY')
    SQLALCHEMY_DATABASE_URI = os.getenv('SQLALCHEMY_DATABASE_URI')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    DEBUG = os.getenv('DEBUG', 'False') == 'True'

    # JWT settings
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY')
    JWT_TOKEN_LOCATION = ['cookies']
    JWT_COOKIE_SECURE = False  # Only send over HTTPS in production
    JWT_COOKIE_CSRF_PROTECT = True  # Enable CSRF protection
    JWT_ACCESS_TOKEN_EXPIRES = 900  # 15 minutes (in seconds)
    JWT_REFRESH_TOKEN_EXPIRES = 2592000  # 30 days (in seconds)
    JWT_ACCESS_COOKIE_NAME = "access_token_cookie"
    JWT_REFRESH_COOKIE_NAME = "refresh_token_cookie"
    JWT_ACCESS_CSRF_COOKIE_NAME = "csrf_access_token"
    JWT_REFRESH_CSRF_COOKIE_NAME = "csrf_refresh_token"

class DevelopmentConfig(Config):
    FLASK_ENV = 'development'
    JWT_COOKIE_SECURE = False  # Allow non-HTTPS in development
    RATELIMIT_STORAGE_URI = "memory://"
    DEBUG = True

class ProductionConfig(Config):
    FLASK_ENV = 'production'
    JWT_COOKIE_SAMESITE = 'Strict'
    RATELIMIT_STORAGE_URI = "memory://"
    DEBUG = False