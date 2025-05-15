import os
from flask import current_app


def upload_profile_photo(file, user_id):
    """Handle profile photo upload and return the filename."""
    if not file:
        return None, "No file provided"

    allowed_extensions = ["jpg", "jpeg", "png", "gif"]
    filename = file.filename
    ext = filename.rsplit(".", 1)[1].lower() if "." in filename else ""
    if ext not in allowed_extensions:
        return None, "Invalid file type. Allowed types: jpg, jpeg, png, gif"

    upload_dir = os.path.join(
        current_app.root_path, "static", "uploads", "profile_photos"
    )
    if not os.path.exists(upload_dir):
        os.makedirs(upload_dir)

    filename = f"user_{user_id}_profile.{ext}"
    file_path = os.path.join(upload_dir, filename)
    try:
        file.save(file_path)
    except Exception as e:
        current_app.logger.error(f"Error saving file: {str(e)}")
        return None, "Upload failed"

    return filename, None
