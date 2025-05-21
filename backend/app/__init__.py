# backend/app/__init__.py
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager, get_jwt
from flask_cors import CORS
from flask_caching import Cache
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import logging
from logging.handlers import RotatingFileHandler
from config import DevelopmentConfig, ProductionConfig
import os


# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
bcrypt = Bcrypt()
jwt = JWTManager()
cors = CORS()
cache = Cache(config={"CACHE_TYPE": "simple"})
limiter = Limiter(get_remote_address, default_limits=["200 per day", "50 per hour"])


@jwt.token_in_blocklist_loader
def check_if_token_revoked(jwt_header, jwt_payload):
    from app.models.token_blacklist import TokenBlacklist

    jti = jwt_payload["jti"]
    return TokenBlacklist.query.filter_by(jti=jti).first() is not None


def create_app(config_class=DevelopmentConfig):
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_object(config_class)

    # Logging (file) in non-debug
    if not app.debug:
        handler = RotatingFileHandler(
            "instance/app.log", maxBytes=10240, backupCount=10
        )
        handler.setFormatter(
            logging.Formatter(
                "%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]"
            )
        )
        handler.setLevel(logging.INFO)
        app.logger.addHandler(handler)
        app.logger.setLevel(logging.INFO)
        app.logger.info("App startup")

    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    bcrypt.init_app(app)
    jwt.init_app(app)
    cache.init_app(app)
    limiter.init_app(app)

    # TEMPORARY: Allow all origins (including HTTP) everywhere
    cors.init_app(
        app,
        resources={
            r"/*": {
                "origins": app.config["CORS_ORIGINS"],
                "supports_credentials": True,
                "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
                "allow_headers": ["Content-Type", "Authorization", "X-CSRF-Token"],
            }
        },
    )

    # Root endpoint
    @app.route("/", methods=["GET"])
    def index():
        return (
            jsonify(
                {
                    "message": "Welcome to the Chess Earn API. Contact developers for API details.",
                    "contact": "developers@chessearn.com",
                }
            ),
            200,
        )

    # Global exception handler
    @app.errorhandler(Exception)
    def handle_exception(e):
        app.logger.error(f"Unhandled Exception: {e}")
        return {"message": "Internal Server Error"}, 500

    # Register blueprints
    from app.routes.auth import auth_bp

    app.register_blueprint(auth_bp, url_prefix="/auth")

    from app.routes.admin.manage_users import manage_users_bp

    app.register_blueprint(manage_users_bp, url_prefix="/admin/users")

    from app.routes.profile import profile_bp

    app.register_blueprint(profile_bp, url_prefix="/profile")

    # Ensure all models are imported
    from app.models import user, token_blacklist, bet, game  # noqa

    return app


# Create app instance
app = create_app(
    ProductionConfig if os.getenv("FLASK_ENV") == "production" else DevelopmentConfig
)

if __name__ == "__main__":
    app.run(host="0.0.0.0")
