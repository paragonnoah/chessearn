from app.models.user import User
from app import db


class AdminUserService:
    @staticmethod
    def get_all_users():
        return User.query.all()

    @staticmethod
    def get_user_by_id(user_id):
        return User.query.get(user_id)

    @staticmethod
    def create_user(data):
        # Check for existing email or username
        if User.query.filter_by(email=data["email"]).first():
            raise ValueError("Email already exists.")
        if User.query.filter_by(username=data["username"]).first():
            raise ValueError("Username already exists.")

        role_upper = data["role"].upper()  # Ensure role is in uppercase to match Enum

        new_user = User(
            first_name=data["first_name"],
            last_name=data["last_name"],
            username=data["username"],
            email=data["email"],
            phone_number=data["phone_number"],
            role=role_upper,
            password=data['password'],
        )
        new_user.set_password(data["password"])
        db.session.add(new_user)
        db.session.commit()
        return new_user

    @staticmethod
    def update_user(user_id, data):
        user = User.query.get(user_id)
        if not user:
            return None

        user.first_name = data.get("first_name", user.first_name)
        user.last_name = data.get("last_name", user.last_name)
        user.username = data.get("username", user.username)
        user.email = data.get("email", user.email)
        user.phone_number = data.get("phone_number", user.phone_number)

        if "role" in data:
            user.role = data["role"].upper()

        if "password" in data:
            user.set_password(data["password"])  # Optional password update

        db.session.commit()
        return user


    @staticmethod
    def delete_user(user_id):
        user = User.query.get(user_id)
        if not user:
            return None
        db.session.delete(user)
        db.session.commit()
        return user

    @staticmethod
    def reset_user_password(user_id, new_password):
        user = User.query.get(user_id)
        if not user:
            return None
        user.set_password(new_password)
        db.session.commit()
        return user
