from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from flask_socketio import SocketIO, emit, join_room, leave_room
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv
import os
from models import db, User

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

# Load environment variables
load_dotenv()
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:yourpassword@localhost/chessearn'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY')
db.init_app(app)
jwt = JWTManager(app)

# Create database tables
with app.app_context():
    db.create_all()

# Store active games (in-memory for now)
active_games = {}

@app.route('/api/users/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': 'Missing username or password'}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({'message': 'Username already exists'}), 400

    hashed_password = generate_password_hash(password)
    new_user = User(username=username, password=hashed_password)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({'message': 'User registered successfully'}), 201

@app.route('/api/users/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    user = User.query.filter_by(username=username).first()
    if not user or not check_password_hash(user.password, password):
        return jsonify({'message': 'Invalid username or password'}), 401

    access_token = create_access_token(identity=user.id)
    return jsonify({'access_token': access_token}), 200

@app.route('/api/games', methods=['GET'])
@jwt_required()
def get_games():
    user_id = get_jwt_identity()
    return jsonify({'message': f'Protected endpoint for user {user_id}'}), 200

@app.route('/')
def hello():
    return 'Hello, ChessEarn!'

# WebSocket events
@socketio.on('connect')
def handle_connect():
    print('Client connected')

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

@socketio.on('join_game')
def handle_join_game(data):
    user_id = data['user_id']
    for game_id, game in list(active_games.items()):
        if len(game['players']) == 1:
            game['players'].append(user_id)
            join_room(game_id)
            emit('game_start', {'game_id': game_id, 'opponent_id': game['players'][0]}, room=game_id)
            return

    game_id = f'game_{len(active_games) + 1}'
    active_games[game_id] = {'players': [user_id], 'moves': []}
    join_room(game_id)
    emit('waiting', {'message': 'Waiting for opponent...'}, room=game_id)

@socketio.on('make_move')
def handle_make_move(data):
    game_id = data['game_id']
    move = data['move']
    user_id = data['user_id']

    if game_id in active_games:
        active_games[game_id]['moves'].append({'user_id': user_id, 'move': move})
        emit('move_made', {'user_id': user_id, 'move': move}, room=game_id)

@socketio.on('leave_game')
def handle_leave_game(data):
    game_id = data['game_id']
    user_id = data['user_id']
    leave_room(game_id)
    if game_id in active_games:
        del active_games[game_id]
    emit('opponent_left', {'message': 'Opponent left the game'}, room=game_id)

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)