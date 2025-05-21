from flask import Blueprint, request, make_response, current_app, jsonify
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    jwt_required,
    get_jwt_identity,
    set_access_cookies,
    set_refresh_cookies,
    unset_jwt_cookies,
    get_jwt,
)
from app import db, limiter
from app.services.auth import authenticate, register_user
from app.models.user import User, UserRole
from app.models.token_blacklist import TokenBlacklist

# Create Blueprint for auth routes
auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/register", methods=["POST"])
def register():
    """Register a new user with PLAYER role."""
    data = request.get_json()
    # Validate required fields
    required_fields = [
        "first_name",
        "last_name",
        "email",
        "username",
        "phone_number",
        "password",
    ]
    if not data or not all(field in data for field in required_fields):
        current_app.logger.error("Registration failed: Missing required fields")
        return jsonify({"error": "Missing required fields"}), 400

    user, error = register_user(
        first_name=data["first_name"],
        last_name=data["last_name"],
        email=data["email"],
        username=data["username"],
        phone_number=data["phone_number"],
        password=data["password"],
    )
    if not user:
        current_app.logger.error(f"Registration failed: {error}")
        return jsonify({"error": "Registration failed"}), 400
    current_app.logger.info(f"User registered: {user.username}")
    return (
        jsonify({"id": user.id, "username": user.username, "role": user.role.value}),
        201,
    )


@auth_bp.route("/login", methods=["POST"])
@limiter.limit("10 per minute")
def login():
    """Log in a user and set access/refresh token cookies."""
    data = request.get_json()
    # Validate required fields
    if not data or "identifier" not in data or "password" not in data:
        current_app.logger.warning("Login failed: Missing identifier or password")
        return jsonify({"error": "Missing identifier or password"}), 400

    user = authenticate(data["identifier"], data["password"])
    if not user:
        current_app.logger.warning(f'Login failed for identifier: {data["identifier"]}')
        return jsonify({"error": "Invalid credentials"}), 401

    access_token = create_access_token(
        identity=user.id, additional_claims={"role": user.role.value}
    )
    refresh_token = create_refresh_token(
        identity=user.id, additional_claims={"role": user.role.value}
    )

    response = make_response(
        {
            "user": {
                "id": user.id,
                "username": user.username,
                "role": user.role.value,
            }
        },
        200,
    )

    set_access_cookies(response, access_token)
    set_refresh_cookies(response, refresh_token)
    current_app.logger.info(f"User logged in: {user.username}")
    return response


@auth_bp.route("/refresh", methods=["POST"])
@jwt_required(refresh=True)
def refresh():
    """Refresh access token using refresh token cookie."""
    user = User.query.get(get_jwt_identity())
    if not user:
        return jsonify({"error": "User not found"}), 401

    access_token = create_access_token(
        identity=user.id, additional_claims={"role": user.role.value}
    )
    response = make_response(
        {
            "user": {
                "id": user.id,
                "username": user.username,
                "role": user.role.value,
            }
        },
        200,
    )
    set_access_cookies(response, access_token)
    return response


@auth_bp.route("/logout", methods=["POST"])
@jwt_required()
def logout():
    """Log out a user by blacklisting JWT and clearing cookies."""
    jti = get_jwt()["jti"]
    token = TokenBlacklist(jti=jti)
    try:
        db.session.add(token)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Logout token blacklist failed: {str(e)}")
        return jsonify({"error": "Logout failed"}), 500

    response = make_response({"message": "Logged out successfully"}, 200)
    unset_jwt_cookies(response)
    current_app.logger.info("User logged out, and token blacklisted")
    return response
