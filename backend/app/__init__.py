from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from config import Config
import logging
from logging.handlers import RotatingFileHandler
import os



# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
bcrypt = Bcrypt()
jwt = JWTManager()
limiter = Limiter(key_func=get_remote_address)

def create_app():
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_object(Config)


    # Set up logging for production
    if not app.debug:
        if not os.path.exists('logs'):
            os.mkdir('logs')
        file_handler = RotatingFileHandler('logs/app.log', maxBytes=10240, backupCount=10)
        file_handler.setFormatter(logging.Formatter(
            '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
        ))
        file_handler.setLevel(logging.INFO)
        app.logger.addHandler(file_handler)
        app.logger.setLevel(logging.INFO)
        app.logger.info('App startup')

    # CORS setup early
    from flask_cors import CORS
    CORS(
        app,
        origins=app.config['CORS_ORIGINS'],
        supports_credentials=True,
        methods=['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
        allow_headers=['Content-Type', 'Authorization', 'X-CSRF-TOKEN']
    )

    # Initialize extensions with app
    db.init_app(app)
    migrate.init_app(app, db)
    bcrypt.init_app(app)
    jwt.init_app(app)
    limiter.init_app(app)

    # Token revocation check
    @jwt.token_in_blocklist_loader
    def check_if_token_revoked(jwt_header, jwt_payload):
        from app.models.token_blacklist import TokenBlacklist
        return TokenBlacklist.is_blacklisted(jwt_payload["jti"])

        

    # Register blueprints
    from app.routes.auth import auth_bp
    from app.routes.profile import profile_bp
    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(profile_bp, url_prefix="/profile")

    from app.cli import clear_old_revoked_tokens

    app.cli.add_command(clear_old_revoked_tokens)

    # Health check and root endpoint
    @app.route('/', methods=['GET'])
    def index():
        return jsonify({
            'message': 'Welcome to the Chess Earn API.',
            'contact': 'developers@chessearn.com'
        }), 200

    @app.route('/health', methods=['GET'])
    def health():
        return jsonify({'status': 'ok'}), 200

    # Test CORS preflight (remove in prod)
    @app.route('/cors-test', methods=['OPTIONS', 'GET'])
    def cors_test():
        if request.method == 'OPTIONS':
            return '', 204
        return jsonify({'message': 'CORS test OK'})

    # Global error handler
    @app.errorhandler(Exception)
    def handle_unhandled_error(e):
        app.logger.exception('Unhandled exception: %s, method: %s, url: %s', e, request.method, request.url)
        return jsonify({'message': 'Internal Server Error'}), 500

    return app

app = create_app()

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=app.config['DEBUG'])