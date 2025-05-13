from flask import current_app
from app import db
from app.models.user import User

def get_user_profile(user_id):
    """Retrieve a user's profile by their ID."""
    user = User.query.get(user_id)
    if not user:
        return None, "User not found"
    return user, None  # Return User object instead of dict

def update_user_photo(user_id, photo_filename):
    """Update a user's profile photo filename."""
    user = User.query.get(user_id)
    if not user:
        return None, "User not found"
    user.photo_filename = photo_filename  # Changed from photo_url
    try:
        db.session.commit()
        return user.to_dict(), None
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error updating user photo: {str(e)}")
        return None, "Update failed"