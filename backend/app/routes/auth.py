from flask import request, make_response, current_app, jsonify
from flask_restx import Namespace, Resource, fields
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

api = Namespace("auth", description="Authentication operations")

# API models
register_model = api.model(
    "Register",
    {
        "first_name": fields.String(required=True, description="First name"),
        "last_name": fields.String(required=True, description="Last name"),
        "email": fields.String(required=True, description="Email address"),
        "username": fields.String(required=True, description="Username"),
        "phone_number": fields.String(required=True, description="Phone number"),
        "password": fields.String(required=True, description="Password"),
    },
)

login_model = api.model(
    "Login",
    {
        "identifier": fields.String(
            required=True, description="Email, username, or phone number"
        ),
        "password": fields.String(required=True, description="Password"),
    },
)

user_model = api.model(
    "User",
    {
        "id": fields.String(description="User ID"),
        "username": fields.String(description="Username"),
        "role": fields.String(description="User role"),
    },
)


@api.route("/register")
class Register(Resource):
    @api.expect(register_model, validate=True)
    @api.response(201, "User registered successfully", user_model)
    @api.response(400, "Registration failed")
    def post(self):
        """Register a new user with PLAYER role."""
        data = request.get_json()
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
            return {"error": "Registration failed"}, 400
        current_app.logger.info(f"User registered: {user.username}")
        return {"id": user.id, "username": user.username, "role": user.role.value}, 201


@api.route("/login")
class Login(Resource):
    @api.expect(login_model, validate=True)
    @api.response(200, "Login successful", user_model)
    @api.response(401, "Invalid credentials")
    @limiter.limit("10 per minute")
    def post(self):
        """Log in a user and set access/refresh token cookies."""
        data = request.get_json()
        user = authenticate(data["identifier"], data["password"])
        if not user:
            current_app.logger.warning(
                f"Login failed for identifier: {data['identifier']}"
            )
            return {"error": "Invalid credentials"}, 401

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


@api.route("/refresh")
class Refresh(Resource):
    @jwt_required(refresh=True)
    @api.response(200, "Token refreshed", user_model)
    @api.response(401, "Invalid refresh token")
    @api.doc(
        description="Refresh access token using refresh token cookie.",
        params={
            "X-CSRF-TOKEN": {
                "description": "CSRF token from the csrf_refresh_token cookie",
                "in": "header",
                "type": "string",
                "required": True,
            }
        },
    )
    def post(self):
        """Refresh access token."""
        user = User.query.get(get_jwt_identity())
        if not user:
            return {"error": "User not found"}, 401

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


@api.route("/logout")
class Logout(Resource):
    @jwt_required()
    @api.response(200, "Logged out successfully")
    @api.doc(
        description="Logs out a user by clearing JWT cookies. Requires the X-CSRF-TOKEN header.",
        params={
            "X-CSRF-TOKEN": {
                "description": "CSRF token from the csrf_access_token cookie",
                "in": "header",
                "type": "string",
                "required": True,
            }
        },
    )
    def post(self):
        """Log out a user by blacklisting JWT and clearing cookies."""
        jti = get_jwt()["jti"]
        token = TokenBlacklist(jti=jti)
        try:
            db.session.add(token)
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f"Logout token blacklist failed: {str(e)}")
            return {"error": "Logout failed"}, 500

        response = make_response({"message": "Logged out successfully"}, 200)
        unset_jwt_cookies(response)
        current_app.logger.info(f"User logged out, and token blacklisted ")
        return response

