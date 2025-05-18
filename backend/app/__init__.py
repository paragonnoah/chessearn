# backend/app/__init__.py
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_caching import Cache
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import logging
from logging.handlers import RotatingFileHandler
import os

from config import Config

# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
bcrypt = Bcrypt()
jwt = JWTManager()
cache = Cache(config={"CACHE_TYPE": "simple"})
limiter = Limiter(key_func=get_remote_address)

@jwt.token_in_blocklist_loader
def check_if_token_revoked(jwt_header, jwt_payload):
    from app.models.token_blacklist import TokenBlacklist
    return bool(TokenBlacklist.query.filter_by(jti=jwt_payload["jti"]).first())


def create_app():
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_object(Config)

    # Logging
    if not app.debug:
        handler = RotatingFileHandler(
            "instance/app.log", maxBytes=10240, backupCount=10
        )
        handler.setLevel(logging.INFO)
        handler.setFormatter(
            logging.Formatter("%(asctime)s %(levelname)s: %(message)s")
        )
        app.logger.addHandler(handler)
        app.logger.setLevel(logging.INFO)
        app.logger.info("App startup")

    # Init extensions
    for ext in (db, migrate, bcrypt, jwt, cache, limiter):
        ext.init_app(app)

    CORS(
        app,
        origins=app.config["CORS_ORIGINS"],
        supports_credentials=True,
        methods=["GET","POST","PUT","DELETE","OPTIONS"],
        allow_headers=["Content-Type","Authorization","X-CSRF-TOKEN"],
    )

    # Blueprints
    from app.routes.auth import auth_bp
    from app.routes.admin.manage_users import manage_users_bp
    from app.routes.profile import profile_bp

    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(manage_users_bp, url_prefix="/admin/users")
    app.register_blueprint(profile_bp, url_prefix="/profile")

    # Root and error handler
    @app.route("/", methods=["GET"])
    def index():
        return jsonify({
            "message": "Welcome to the Chess Earn API.",
            "contact": "developers@chessearn.com",
        }), 200

    @app.errorhandler(Exception)
    def handle_exception(e):
        app.logger.error(f"Unhandled Exception: {e}")
        return {"message": "Internal Server Error"}, 500

    # Import models to register
    from app.models import user, token_blacklist, bet, game  # noqa

    return app

app = create_app()

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=app.config['DEBUG'])
