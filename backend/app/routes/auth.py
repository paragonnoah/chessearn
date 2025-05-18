# backend/app/routes/auth.py
from flask import Blueprint, request, jsonify, make_response
from flask_jwt_extended import (
    create_access_token, create_refresh_token,
    jwt_required, get_jwt_identity,
    set_access_cookies, set_refresh_cookies,
    unset_jwt_cookies, get_jwt
)

from app.services.auth import authenticate, register_user
from app.models.user import User
from app import limiter, db
from app.models.token_blacklist import TokenBlacklist

auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json() or {}
    user, error = register_user(**data)
    if error:
        return jsonify({"error": error}), 400
    return jsonify({"id": user.id, "username": user.username}), 201


@auth_bp.route("/login", methods=["POST"])
@limiter.limit("10/minute")
def login():
    data = request.get_json() or {}
    user = authenticate(data.get('identifier'), data.get('password'))
    if not user:
        return jsonify({"error": "Invalid credentials"}), 401

    access_token = create_access_token(identity=user.id, additional_claims={"role": user.role.value})
    refresh_token = create_refresh_token(identity=user.id, additional_claims={"role": user.role.value})
    resp = make_response(jsonify({"user": {"id": user.id, "username": user.username}}), 200)
    set_access_cookies(resp, access_token)
    set_refresh_cookies(resp, refresh_token)
    return resp


@auth_bp.route("/refresh", methods=["POST"])
@jwt_required(refresh=True)
def refresh():
    current_user = User.query.get(get_jwt_identity())
    access_token = create_access_token(identity=current_user.id, additional_claims={"role": current_user.role.value})
    resp = make_response(jsonify({"user": {"id": current_user.id, "username": current_user.username}}), 200)
    set_access_cookies(resp, access_token)
    return resp



@auth_bp.route("/logout", methods=["POST"])
@jwt_required()
def logout():
    # 1) Grab the token's JTI, not the user ID
    jti = get_jwt()["jti"]

    # 2) Blacklist it (ignore if already there)
    try:
        db.session.add(TokenBlacklist(jti=jti))
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        current_app.logger.info(f"Token JTI {jti} was already blacklisted.")

    # 3) Clear cookies client‐side
    resp = make_response(jsonify({"message": "Logged out"}), 200)
    unset_jwt_cookies(resp)
    return resp