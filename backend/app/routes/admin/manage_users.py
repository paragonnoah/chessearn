from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from app.utils.role_decorator import role_required
from app.services.admin.user_service import AdminUserService
from app.models.user import UserRole

# Create Blueprint for admin user management routes
manage_users_bp = Blueprint('manage_users', __name__)

@manage_users_bp.route('/', methods=['GET'])
@jwt_required()
@role_required('admin')
def get_users():
    """List all users."""
    users = AdminUserService.get_all_users()
    return jsonify(users)

@manage_users_bp.route('/', methods=['POST'])
@jwt_required()
@role_required('admin')
def create_user():
    """Create a new user."""
    data = request.get_json()
    # Validate required fields
    required_fields = ['first_name', 'last_name', 'username', 'email', 'phone_number', 'role', 'password']
    if not data or not all(field in data for field in required_fields):
        return jsonify({'error': 'Missing required fields'}), 400

    try:
        user = AdminUserService.create_user(data)
        return jsonify(user), 201
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

@manage_users_bp.route('/<string:user_id>', methods=['GET'])
@jwt_required()
@role_required('admin')
def get_user(user_id):
    """Get user by ID."""
    user = AdminUserService.get_user_by_id(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404
    return jsonify(user)

@manage_users_bp.route('/<string:user_id>', methods=['PUT'])
@jwt_required()
@role_required('admin')
def update_user(user_id):
    """Update user."""
    data = request.get_json()
    # Validate that at least one field is provided
    if not data:
        return jsonify({'error': 'No data provided'}), 400

    updated = AdminUserService.update_user(user_id, data)
    if not updated:
        return jsonify({'error': 'User not found'}), 404
    return jsonify(updated)

@manage_users_bp.route('/<string:user_id>', methods=['DELETE'])
@jwt_required()
@role_required('admin')
def delete_user(user_id):
    """Delete user."""
    deleted = AdminUserService.delete_user(user_id)
    if not deleted:
        return jsonify({'error': 'User not found'}), 404
    return jsonify({'message': 'User deleted'})

@manage_users_bp.route('/<string:user_id>/reset-password', methods=['POST'])
@jwt_required()
@role_required('admin')
def reset_password(user_id):
    """Reset a user's password."""
    data = request.get_json()
    if not data or 'password' not in data:
        return jsonify({'error': 'Missing password'}), 400

    result = AdminUserService.reset_user_password(user_id, data['password'])
    if not result:
        return jsonify({'error': 'User not found'}), 404
    return jsonify({'message': 'Password reset successfully'})

@manage_users_bp.route('/roles', methods=['GET'])
@jwt_required()
@role_required('admin')
def get_roles():
    """Get all available user roles."""
    roles = []
    for role in UserRole:
        if isinstance(role.value, tuple):
            value, label = role.value
        else:
            value, label = role.value, role.name.capitalize()
        roles.append({'value': value, 'label': label})
    return jsonify({'roles': roles})