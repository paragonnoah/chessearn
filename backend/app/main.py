from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
from dotenv import load_dotenv
import os
import bcrypt
import stripe
import requests

app = Flask(__name__)
CORS(app)

# Load environment variables
load_dotenv()
DATABASE_URL = os.getenv('DATABASE_URL')
ADMIN_API_KEY = "your-admin-api-key-12345"
STRIPE_SECRET_KEY = os.getenv('STRIPE_SECRET_KEY')  # Add your Stripe test key
MPESA_CONSUMER_KEY = os.getenv('MPESA_CONSUMER_KEY')
MPESA_CONSUMER_SECRET = os.getenv('MPESA_CONSUMER_SECRET')
MPESA_PASSKEY = os.getenv('MPESA_PASSKEY')

# Stripe configuration
stripe.api_key = STRIPE_SECRET_KEY

# Database connection
def get_db_connection():
    conn = psycopg2.connect(DATABASE_URL)
    return conn

# Add balance column to users table (run this in psql)
# ALTER TABLE users ADD COLUMN balance DECIMAL(10, 2) DEFAULT 0.0;

@app.route('/api/users/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    if not username or not email or not password:
        return jsonify({'message': 'Missing required fields'}), 400

    password_hash = password  # Plain text for MVP

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            'INSERT INTO users (username, email, password) VALUES (%s, %s, %s) RETURNING id',
            (username, email, password_hash)
        )
        user_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'access_token': f'mock_token_{user_id}'}), 201
    except psycopg2.Error as e:
        if 'unique constraint' in str(e).lower():
            return jsonify({'message': 'Username or email already exists'}), 400
        return jsonify({'message': 'Database error'}), 500

@app.route('/api/users/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': 'Missing username or password'}), 400

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT id, password FROM users WHERE username = %s', (username,))
        user = cur.fetchone()
        cur.close()
        conn.close()

        if user:
            user_id, stored_password = user
            if password == stored_password:
                return jsonify({'access_token': f'mock_token_{user_id}'}), 200
            return jsonify({'message': 'Invalid password'}), 401
        return jsonify({'message': 'User not found'}), 404
    except psycopg2.Error as e:
        return jsonify({'message': 'Database error'}), 500

@app.route('/api/admin/users', methods=['GET'])
def get_users():
    api_key = request.headers.get('X-API-Key')
    if api_key != ADMIN_API_KEY:
        return jsonify({'message': 'Unauthorized'}), 401

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT id, username, email, created_at FROM users')
        users = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify([{
            'id': user[0],
            'username': user[1],
            'email': user[2],
            'created_at': user[3].isoformat()
        } for user in users]), 200
    except psycopg2.Error as e:
        return jsonify({'message': 'Database error'}), 500

@app.route('/api/payments/deposit', methods=['POST'])
def deposit():
    data = request.get_json()
    amount = data.get('amount')  # Amount in cents (Stripe) or KES (M-Pesa)
    method = data.get('method')  # 'stripe' or 'mpesa'
    user_id = data.get('user_id')  # Extract from token in production

    if not amount or not method or not user_id:
        return jsonify({'message': 'Missing required fields'}), 400

    try:
        conn = get_db_connection()
        cur = conn.cursor()

        if method == 'stripe':
            # Mock Stripe payment (replace with real intent in production)
            payment_intent = stripe.PaymentIntent.create(
                amount=amount,  # e.g., 100 cents = $1
                currency='usd',
                payment_method_types=['card'],
                metadata={'user_id': user_id},
            )
            # Simulate success for MVP
            cur.execute(
                'UPDATE users SET balance = balance + %s WHERE id = %s',
                (amount / 100.0, user_id)
            )
            conn.commit()
            return jsonify({'message': 'Stripe deposit successful', 'client_secret': payment_intent.client_secret}), 200

        elif method == 'mpesa':
            # Mock M-Pesa STK Push (replace with real API call)
            # For sandbox, you need a Kenyan phone number for testing
            # This is a simplified mock
            cur.execute(
                'UPDATE users SET balance = balance + %s WHERE id = %s',
                (amount, user_id)
            )
            conn.commit()
            return jsonify({'message': 'M-Pesa deposit successful'}), 200

        else:
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