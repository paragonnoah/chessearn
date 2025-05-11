from flask import Flask, request, jsonify, redirect, url_for
from flask_cors import CORS
import psycopg2
from dotenv import load_dotenv
import os
import bcrypt
import stripe
import requests
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from requests_oauthlib import OAuth2Session
import random

app = Flask(__name__)
CORS(app)

# Load environment variables
load_dotenv()
DATABASE_URL = os.getenv('DATABASE_URL')
ADMIN_API_KEY = "your-admin-api-key-12345"
STRIPE_SECRET_KEY = os.getenv('STRIPE_SECRET_KEY')
GOOGLE_CLIENT_ID = os.getenv('GOOGLE_CLIENT_ID')
GOOGLE_CLIENT_SECRET = os.getenv('GOOGLE_CLIENT_SECRET')
X_CLIENT_ID = os.getenv('X_CLIENT_ID')
X_CLIENT_SECRET = os.getenv('X_CLIENT_SECRET')
MPESA_CONSUMER_KEY = os.getenv('MPESA_CONSUMER_KEY')
MPESA_CONSUMER_SECRET = os.getenv('MPESA_CONSUMER_SECRET')
MPESA_PASSKEY = os.getenv('MPESA_PASSKEY')

stripe.api_key = STRIPE_SECRET_KEY

def get_db_connection():
    conn = psycopg2.connect(DATABASE_URL)
    return conn

# Initialize database with phone_number column if not exists
def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('''
        DO $$ BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM information_schema.columns 
                WHERE table_name = 'users' AND column_name = 'phone_number'
            ) THEN
                ALTER TABLE users ADD COLUMN phone_number VARCHAR(15);
                ALTER TABLE users ADD COLUMN verification_code VARCHAR(6);
                ALTER TABLE users ADD COLUMN is_verified BOOLEAN DEFAULT FALSE;
            END IF;
        END $$;
    ''')
    conn.commit()
    cur.close()
    conn.close()

init_db()

@app.route('/api/auth/google')
def google_login():
    redirect_uri = url_for('google_callback', _external=True)
    return redirect(f'https://accounts.google.com/o/oauth2/v2/auth?client_id={GOOGLE_CLIENT_ID}&redirect_uri={redirect_uri}&response_type=code&scope=profile email&access_type=offline')

@app.route('/api/auth/google/callback')
def google_callback():
    code = request.args.get('code')
    redirect_uri = url_for('google_callback', _external=True)
    token_url = 'https://oauth2.googleapis.com/token'
    token_data = {
        'code': code,
        'client_id': GOOGLE_CLIENT_ID,
        'client_secret': GOOGLE_CLIENT_SECRET,
        'redirect_uri': redirect_uri,
        'grant_type': 'authorization_code',
    }
    token_response = requests.post(token_url, data=token_data).json()
    id_info = id_token.verify_oauth2_token(token_response['id_token'], google_requests.Request(), GOOGLE_CLIENT_ID)
    email = id_info['email']
    name = id_info.get('name', f'google_user_{email.split("@")[0]}')

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id, username FROM users WHERE email = %s', (email,))
    user = cur.fetchone()
    if user:
        user_id, username = user
    else:
        cur.execute('INSERT INTO users (username, email, password) VALUES (%s, %s, %s) RETURNING id', (name, email, 'social'))
        user_id = cur.fetchone()[0]
        conn.commit()
    cur.close()
    conn.close()
    token = f'mock_token_{user_id}'
    return redirect(f'https://play.chessearn.com/?token={token}')

@app.route('/api/auth/x')
def x_login():
    redirect_uri = url_for('x_callback', _external=True)
    x = OAuth2Session(X_CLIENT_ID, redirect_uri=redirect_uri)
    authorization_url, state = x.authorization_url('https://api.x.com/2/oauth2/authorize')
    return redirect(authorization_url)

@app.route('/api/auth/x/callback')
def x_callback():
    code = request.args.get('code')
    redirect_uri = url_for('x_callback', _external=True)
    token_url = 'https://api.x.com/2/oauth2/token'
    token_data = {
        'code': code,
        'client_id': X_CLIENT_ID,
        'client_secret': X_CLIENT_SECRET,
        'redirect_uri': redirect_uri,
        'grant_type': 'authorization_code',
    }
    token_response = requests.post(token_url, data=token_data).json()
    access_token = token_response['access_token']
    user_response = requests.get(
        'https://api.x.com/2/users/me',
        headers={'Authorization': f'Bearer {access_token}'}
    ).json()
    email = user_response.get('email', f'x_user_{user_response["id"]}')
    name = user_response.get('name', f'x_user_{user_response["id"]}')

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id, username FROM users WHERE email = %s', (email,))
    user = cur.fetchone()
    if user:
        user_id, username = user
    else:
        cur.execute('INSERT INTO users (username, email, password) VALUES (%s, %s, %s) RETURNING id', (name, email, 'social'))
        user_id = cur.fetchone()[0]
        conn.commit()
    cur.close()
    conn.close()
    token = f'mock_token_{user_id}'
    return redirect(f'https://play.chessearn.com/?token={token}')

@app.route('/api/users/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')
    phone_number = data.get('phone_number')
    if not username or not email or not password or not phone_number:
        return jsonify({'message': 'Missing required fields'}), 400
    password_hash = password  # In production, use bcrypt.hashpw(password.encode(), bcrypt.gensalt())
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('INSERT INTO users (username, email, password, phone_number) VALUES (%s, %s, %s, %s) RETURNING id', (username, email, password_hash, phone_number))
        user_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'access_token': f'mock_token_{user_id}', 'message': 'Registration successful, please verify phone'}), 201
    except psycopg2.Error as e:
        if 'unique constraint' in str(e).lower():
            return jsonify({'message': 'Username or email already exists'}), 400
        return jsonify({'message': 'Database error'}), 500

@app.route('/api/users/send-verification', methods=['POST'])
def send_verification():
    data = request.get_json()
    phone_number = data.get('phone_number')
    if not phone_number:
        return jsonify({'message': 'Phone number is required'}), 400
    verification_code = str(random.randint(100000, 999999))
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('UPDATE users SET verification_code = %s, is_verified = FALSE WHERE phone_number = %s', (verification_code, phone_number))
        conn.commit()
        cur.close()
        conn.close()
        # In production, send SMS via Twilio or similar
        return jsonify({'message': 'Verification code sent', 'code': verification_code}), 200  # Mock code for testing
    except psycopg2.Error as e:
        return jsonify({'message': 'Database error'}), 500

@app.route('/api/users/verify-phone', methods=['POST'])
def verify_phone():
    data = request.get_json()
    phone_number = data.get('phone_number')
    verification_code = data.get('verification_code')
    if not phone_number or not verification_code:
        return jsonify({'message': 'Phone number and verification code are required'}), 400
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT verification_code, is_verified FROM users WHERE phone_number = %s', (phone_number,))
        user = cur.fetchone()
        if user and user[0] == verification_code and not user[1]:
            cur.execute('UPDATE users SET is_verified = TRUE WHERE phone_number = %s', (phone_number,))
            conn.commit()
            cur.close()
            conn.close()
            return jsonify({'message': 'Phone verified successfully'}), 200
        return jsonify({'message': 'Invalid or already verified code'}), 400
    except psycopg2.Error as e:
        return jsonify({'message': 'Database error'}), 500

@app.route('/api/users/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    reentered_password = data.get('reentered_password')
    phone_number = data.get('phone_number')
    if not email or not password or not reentered_password or not phone_number:
        return jsonify({'message': 'Missing required fields'}), 400
    if password != reentered_password:
        return jsonify({'message': 'Passwords do not match'}), 400
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT id, password, is_verified FROM users WHERE email = %s AND phone_number = %s', (email, phone_number))
        user = cur.fetchone()
        cur.close()
        conn.close()
        if user and user[1] == password and user[2]:
            return jsonify({'access_token': f'mock_token_{user[0]}'}), 200
        elif user and not user[2]:
            return jsonify({'message': 'Phone number not verified'}), 401
        return jsonify({'message': 'Invalid credentials'}), 401
    except psycopg2.Error as e:
        return jsonify({'message': 'Database error'}), 500

@app.route('/api/payments/deposit', methods=['POST'])
def deposit():
    data = request.get_json()
    amount = data.get('amount')
    method = data.get('method')
    user_id = data.get('user_id')
    if not amount or not method or not user_id:
        return jsonify({'message': 'Missing required fields'}), 400
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        if method == 'stripe':
            payment_intent = stripe.PaymentIntent.create(amount=amount, currency='usd', payment_method_types=['card'], metadata={'user_id': user_id})
            cur.execute('UPDATE users SET balance = balance + %s WHERE id = %s', (amount / 100.0, user_id))
            conn.commit()
            return jsonify({'message': 'Stripe deposit successful', 'client_secret': payment_intent.client_secret}), 200
        return jsonify({'message': 'Unsupported payment method'}), 400
    except Exception as e:
        return jsonify({'message': f'Payment error: {str(e)}'}), 500
    finally:
        cur.close()
        conn.close()

@app.route('/')
def hello():
    return 'Hello, ChessEarn!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)