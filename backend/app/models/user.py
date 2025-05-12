from app import db
from flask_bcrypt import generate_password_hash, check_password_hash
from enum import Enum
import uuid


class UserRole(Enum):
    ADMIN = "admin"
    PLAYER = "player"
    DEVELOPER = ("developer", "masharia47th+paragonnoah")


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    phone_number = db.Column(db.String(15), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(128), nullable=False)
    role = db.Column(db.Enum(UserRole), default=UserRole.PLAYER, nullable=False)

    def __init__(
        self,
        first_name,
        last_name,
        email,
        username,
        phone_number,
        password,
        role=UserRole.PLAYER,
    ):
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.username = username
        self.phone_number = phone_number
        self.set_password(password)
        self.role = role

    def set_password(self, password):
        self.password_hash = generate_password_hash(password).decode("utf-8")

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
    # Ensure you handle both regular and tuple-based enums
        if isinstance(self.role.value, tuple):
            role_value = self.role.value[0]
        else:
            role_value = self.role.value

        return {
            "id": self.id,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email": self.email,
            "username": self.username,
            "phone_number": self.phone_number,
            "role": role_value,  # Only the string value, not the enum member
        }


    def __repr__(self):
        return f"<User {self.username} ({self.email}) - Role: {self.role.value}>"
