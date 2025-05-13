from flask import current_app
from app import db
from app.models.user import User, UserRole
from email_validator import validate_email, EmailNotValidError
import phonenumbers

def is_valid_phone_number(phone):
    try:
        parsed = phonenumbers.parse(phone, None)
        return phonenumbers.is_valid_number(parsed)
    except phonenumbers.NumberParseException:
        return False


def authenticate(identifier, password):
    """Authenticate a user by email, username, or phone number."""
    user = User.query.filter(
        (User.email == identifier)
        | (User.username == identifier)
        | (User.phone_number == identifier)
    ).first()
    if user and user.check_password(password):
        return user
    current_app.logger.warning(f"Authentication failed for identifier: {identifier}")
    return None


def register_user(first_name, last_name, email, username, phone_number, password):
    """Register a new user with PLAYER role."""
    try:
        validate_email(email)
    except EmailNotValidError:
        current_app.logger.error(f"Invalid email format: {email}")
        return None, "Invalid registration data"
    if not is_valid_phone_number(phone_number):
        current_app.logger.error(f"Invalid phone number: {phone_number}")
        return None, "Invalid registration data"
    if len(password) < 8:
        current_app.logger.error(f"Password too short for username: {username}")
        return None, "Invalid registration data"

    if User.query.filter(
        (User.email == email)
        | (User.username == username)
        | (User.phone_number == phone_number)
    ).first():
        current_app.logger.warning(
            f"Duplicate user detected: email={email}, username={username}, phone={phone_number}"
        )
        return None, "User already exists"

    user = User(
        first_name=first_name,
        last_name=last_name,
        email=email,
        username=username,
        phone_number=phone_number,
        password=password,
        role=UserRole.PLAYER,
    )
    try:
        db.session.add(user)
        db.session.commit()
        current_app.logger.info(f"User created: {username}")
        return user, None
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Database error during registration: {str(e)}")
        return None, "Registration failed"
