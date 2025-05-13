from flask import Blueprint, request, jsonify, url_for, abort, send_from_directory
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.profile import get_user_profile, update_user_photo
from app.utils.image_upload import upload_profile_photo
from werkzeug.utils import secure_filename
import os
from flask import current_app

profile_bp = Blueprint('profile', __name__)

@profile_bp.route('', methods=['GET'])
@jwt_required()
def get_profile():
    """Get the current user's profile."""
    user_id = get_jwt_identity()
    user, error = get_user_profile(user_id)
    if error:
        return jsonify({'error': error}), 404
    user_data = user.to_dict()
    if user.photo_filename:
        user_data['photo_url'] = url_for('profile.get_photo', user_id=user.id, _external=True)
    else:
        user_data['photo_url'] = None
    return jsonify(user_data), 200

@profile_bp.route('/photo', methods=['POST'])
@jwt_required()
def upload_photo():
    """Upload a profile photo for the current user."""
    user_id = get_jwt_identity()
    if 'photo' not in request.files:
        return jsonify({'error': 'No photo file provided'}), 400
    
    file = request.files['photo']
    filename, error = upload_profile_photo(file, user_id)
    if error:
        return jsonify({'error': error}), 400
    
    _, error = update_user_photo(user_id, filename)
    if error:
        return jsonify({'error': error}), 500
    
    return jsonify({'message': 'Photo uploaded successfully'}), 200

@profile_bp.route('/photo/<user_id>', methods=['GET'])
def get_photo(user_id):
    """Serve the profile photo for a given user."""
    user = User.query.get(user_id)
    if not user or not user.photo_filename:
        abort(404)
    filename = secure_filename(user.photo_filename)
    uploads_dir = os.path.join(current_app.root_path, 'static', 'uploads', 'profile_photos')
    return send_from_directory(uploads_dir, filename)