from flask_restx import Namespace, Resource, fields
from flask import request
from flask_jwt_extended import jwt_required
from app.utils.role_decorator import role_required
from app.services.admin.user_service import AdminUserService
from app.models.user import UserRole

api = Namespace("admin/users", description="Admin user management")

user_model = api.model(
    "User",
    {
        "id": fields.String(readOnly=True),
        "first_name": fields.String(required=True),
        "last_name": fields.String(required=True),
        "username": fields.String(required=True),
        "email": fields.String(required=True),
        "phone_number": fields.String(required=True),
        "role": fields.String(required=True),
    },
)

user_create_model = api.clone(
    "UserCreate",
    user_model,
    {
        "password": fields.String(required=True),
    },
)

password_model = api.model("ResetPassword", {"password": fields.String(required=True)})


@api.route("/")
class Users(Resource):
    @jwt_required()
    @role_required("admin")
    @api.marshal_list_with(user_model)
    def get(self):
        """List all users"""
        return AdminUserService.get_all_users()

    @jwt_required()
    @role_required("admin")
    @api.expect(user_create_model)
    @api.marshal_with(user_model)
    def post(self):
        """Create a new user"""
        try:
            return AdminUserService.create_user(request.json)
        except ValueError as e:
            api.abort(400, str(e))


@api.route("/<string:user_id>")
@api.param("user_id", "The user ID")
class UserResource(Resource):
    @jwt_required()
    @role_required("admin")
    @api.marshal_with(user_model)
    def get(self, user_id):
        """Get user by ID"""
        user = AdminUserService.get_user_by_id(user_id)
        if not user:
            api.abort(404, "User not found")
        return user

    @jwt_required()
    @role_required("admin")
    @api.expect(user_model)
    @api.marshal_with(user_model)
    def put(self, user_id):
        """Update user"""
        updated = AdminUserService.update_user(user_id, request.json)
        if not updated:
            api.abort(404, "User not found")
        return updated

    @jwt_required()
    @role_required("admin")
    def delete(self, user_id):
        """Delete user"""
        deleted = AdminUserService.delete_user(user_id)
        if not deleted:
            api.abort(404, "User not found")
        return {"message": "User deleted"}


@api.route("/<string:user_id>/reset-password")
@api.param("user_id", "The user ID")
class ResetPassword(Resource):
    @jwt_required()
    @role_required("admin")
    @api.expect(password_model)
    def post(self, user_id):
        """Reset a user's password"""
        password = request.json.get("password")
        result = AdminUserService.reset_user_password(user_id, password)
        if not result:
            api.abort(404, "User not found")
        return {"message": "Password reset successfully"}


@api.route("/roles")
class UserRoles(Resource):
    @jwt_required()
    @role_required("admin")
    def get(self):
        """Get all available user roles"""
        roles = []
        for role in UserRole:
            if isinstance(role.value, tuple):
                value, label = role.value
            else:
                value, label = role.value, role.name.capitalize()
            roles.append({"value": value, "label": label})
        return {"roles": roles}
