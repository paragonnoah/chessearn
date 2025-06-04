curl -X POST https://api.chessearn.com/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@gmail.com",
    "username": "johndoe",
    "phone_number": "+254759662970",
    "password": "securepassword123"
  }'

  expected results 
  {"message": "User created"}

  Login

Test with email:
bash
curl -X POST  https://api.chessearn.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "masharia47th",
    "password": "kiveeese"
  }'

Test with username:
bash
curl -X POST https://api.chessearn.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "johndoe",
    "password": "securepassword123"
  }'

Test with phone number:
bash
curl -X POST https://api.chessearn.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "+254759662970",
    "password": "securepassword123"
  }'

Expected Response (for any valid identifier):
json
{
  "message": "Login successful",
  "user": {
    "id": "some-uuid",
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@gmail.com",
    "username": "johndoe",
    "phone_number": "+254759662970",
    "role": "player",
    "ranking": 800,
    "wallet_balance": 0.0,
    "is_active": true,
    "is_verified": false
  },
  "access_token": "jwt-access-token",
  "refresh_token": "jwt-refresh-token"
}

Error Response (invalid identifier or password):
json
{"message": "Invalid credentials"}

3. Refresh

Use the refresh_token from the login response:
bash
curl -X POST https://api.chessearn.com/auth/refresh \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer jwt-refresh-token"

Expected Response:
json
{
  "message": "Access token refreshed",
  "access_token": "new-jwt-access-token"
}

Error Response (Invalid Refresh Token):
json
{"message": "Invalid token"}