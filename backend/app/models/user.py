from app import db
from flask_bcrypt import generate_password_hash, check_password_hash
from enum import Enum
import uuid
from sqlalchemy.dialects.postgresql import ENUM


class UserRole(Enum):
    ADMIN = "admin"
    PLAYER = "player"
    DEVELOPER = "developer"


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    phone_number = db.Column(db.String(20), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(256), nullable=False)
    role = db.Column(
        ENUM(UserRole, name="userrole", create_type=False),
        default=UserRole.PLAYER,
        nullable=False,
    )
    ranking = db.Column(db.Integer, default=800)
    photo_filename = db.Column(db.String(255), nullable=True)
    wallet_balance = db.Column(db.Float, default=0.0)
    is_active = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=False)

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
        self.email = email.lower()
        self.username = username
        self.phone_number = phone_number
        self.set_password(password)
        self.role = role
        self.photo_filename = None  # Initialize as None

    def set_password(self, password):
        self.password_hash = generate_password_hash(password).decode("utf-8")

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        role_value = (
            self.role.value if isinstance(self.role.value, str) else self.role.value[0]
        )
        return {
            "id": self.id,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email": self.email,
            "username": self.username,
            "phone_number": self.phone_number,
            "role": role_value,
            "ranking": self.ranking,
            "wallet_balance": self.wallet_balance,
            "is_active": self.is_active,
            "is_verified": self.is_verified,
        }

    def __repr__(self):
        return f"<User {self.username} ({self.email}) - Role: {self.role.value}>"
