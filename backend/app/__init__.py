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
    cors.init_app(app, resources={r"/*": {"origins": "*", "supports_credentials": True}})
    cache.init_app(app)
    limiter.init_app(app)

    # Root endpoint
    @app.route('/', methods=['GET'])
    def index():
        """Display API contact message."""
        return jsonify({
            'message': 'Welcome to the Chess Earn API. Contact developers for API details.',
            'contact': 'developers@chessearn.com'  # Replace with actual contact
        }), 200

    @app.errorhandler(Exception)
    def handle_exception(e):
        app.logger.error(f"Unhandled Exception: {str(e)}")
        return {"message": "Internal Server Error"}, 500

    # Register blueprints
    from app.routes.auth import auth_bp
    app.register_blueprint(auth_bp, url_prefix="/auth")

    from app.routes.admin.manage_users import manage_users_bp
    app.register_blueprint(manage_users_bp, url_prefix="/admin/users")

    from app.routes.profile import profile_bp
    app.register_blueprint(profile_bp, url_prefix='/profile')

    from app.models import user, token_blacklist, bet, game

    return app

app = create_app()

if __name__ == "__main__":
    app.run()