from functools import wraps
from flask_jwt_extended import get_jwt_identity
from app.models.user import User


def role_required(*roles):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            user_id = get_jwt_identity()
            if not user_id:
                return {"message": "Missing or invalid token"}, 401

            user = User.query.get(user_id)
            if not user:
                return {"message": "User not found"}, 404

            # Convert user's role and required roles to lowercase for comparison.
            user_role = (
                user.role.value.lower()
                if hasattr(user.role, "value")
                else str(user.role).lower()
            )
            allowed_roles = [role.lower() for role in roles]

            if user_role not in allowed_roles:
                return {"message": "Access forbidden: insufficient role"}, 403

            return func(*args, **kwargs)

        return wrapper

    return decorator
