from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager, get_jwt
from flask_restx import Api
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
api = Api(
    title="CHESS EARN API",
    version="1.0",
    description="Lets earn through chess",
)
cache = Cache(config={"CACHE_TYPE": "simple"})
limiter = Limiter(get_remote_address, default_limits=["200 per day", "50 per hour"])


@jwt.token_in_blocklist_loader
def check_if_token_revoked(jwt_header, jwt_payload):
    jti = jwt_payload["jti"]
    from app.models.token_blacklist import TokenBlacklist

    token = TokenBlacklist.query.filter_by(jti=jti).first()
    return token is not None


def create_app(config_class=DevelopmentConfig):
    app = Flask(__name__)
    app.config.from_object(config_class)
    if not app.debug:
        file_handler = RotatingFileHandler(
            "instance/app.log", maxBytes=10240, backupCount=10
        )
        file_handler.setFormatter(
            logging.Formatter(
                "%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]"
            )
        )
        file_handler.setLevel(logging.INFO)
        app.logger.addHandler(file_handler)
        app.logger.setLevel(logging.INFO)
        app.logger.info("App startup")

    db.init_app(app)
    migrate.init_app(app, db)
    bcrypt.init_app(app)
    jwt.init_app(app)
    api.init_app(app)
    cors.init_app(
        app, resources={r"/*": {"origins": "*", "supports_credentials": True}}
    )
    cache.init_app(app)
    limiter.init_app(app)

    @app.errorhandler(Exception)
    def handle_exception(e):
        app.logger.error(f"Unhandled Exception: {str(e)}")
        return {"message": "Internal Server Error"}, 500

    from app.routes.auth import api as auth_ns
    from app.routes.admin.manage_users import api as manage_users_ns

    api.add_namespace(auth_ns, path="/auth")
    api.add_namespace(manage_users_ns, path="/admin/users")
    

    from app.models import user, token_blacklist

    return app


app = create_app()

if __name__ == "__main__":
    app.run()
