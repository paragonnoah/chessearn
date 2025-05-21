# backend/app/services/auth.py
from flask import current_app
from app import db
from app.models.user import User, UserRole
from email_validator import validate_email, EmailNotValidError
import phonenumbers
from phonenumbers import NumberParseException
import re


def is_valid_phone_number(phone: str) -> bool:
    """
    Expects something like:
      • '254755443382'
      • '+254755443382'
      • '254‑755‑443‑382'
    Strips formatting, forces a '+' prefix, then has phonenumbers do the rest.
    """
    # 1) Keep only digits and '+' (drop spaces, dashes, parentheses, etc.)
    cleaned = re.sub(r"[^\d+]", "", phone.strip())

    # 2) Ensure leading '+'
    if not cleaned.startswith("+"):
        cleaned = "+" + cleaned

    # 3) Parse & validate
    try:
        parsed = phonenumbers.parse(cleaned, None)
    except NumberParseException as e:
        current_app.logger.error(f"Phone parse error for '{phone}': {e}")
        return False

    if phonenumbers.is_valid_number(parsed):
        return True

    current_app.logger.warning(f"Phone number not valid after parsing: {parsed}")
    return False


def authenticate(identifier, password):
    user = User.query.filter(
        (User.email == identifier)
        | (User.username == identifier)
        | (User.phone_number == identifier)
    ).first()
    if user and user.check_password(password):
        return user
    current_app.logger.warning(f"Auth failed for {identifier}")
    return None


def register_user(**kwargs):
    try:
        validate_email(kwargs["email"])
        if not is_valid_phone_number(kwargs["phone_number"]):
            raise ValueError("Invalid phone number")
        if len(kwargs["password"]) < 8:
            raise ValueError("Password too short")
    except (EmailNotValidError, ValueError) as e:
        current_app.logger.error(f"Registration error: {e}")
        return None, str(e)

    duplicate = User.query.filter(
        (User.email == kwargs["email"])
        | (User.username == kwargs["username"])
        | (User.phone_number == kwargs["phone_number"])
    ).first()
    if duplicate:
        return None, "User already exists"

    user = User(**kwargs, role=UserRole.PLAYER)
    db.session.add(user)
    try:
        db.session.commit()
        current_app.logger.info(f"User created: {user.username}")
        return user, None
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"DB commit error: {e}")
        return None, "Registration failed"
