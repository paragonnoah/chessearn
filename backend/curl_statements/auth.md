# 1. Register
curl -X POST http://192.168.100.8:5000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@gmail.com",
    "username": "johndoe",
    "phone_number": "+254765463349",
    "password": "securepassword"
  }'

# Expected JSON:
# {
#   "id": "4630c82d-ea76-4409-a9c2-f6cb1a5c3dff",
#   "role": "player",
#   "username": "johndoe"
# }

# 2. Login (saves cookies to cookies.txt)
curl -X POST http://192.168.100.8:5000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "johndoe",
    "password": "securepassword"
  }' \
  -c cookies.txt

# Expected JSON:
# {
#   "user": {
#     "id": "4630c82d-ea76-4409-a9c2-f6cb1a5c3dff",
#     "role": "player",
#     "username": "johndoe"
#   }
# }

# 3. Refresh (reads refresh cookie, issues new access cookie)
curl -X POST http://192.168.100.8:5000/auth/refresh \
  -b cookies.txt \
  -c cookies.txt

# Expected JSON:
# {
#   "user": {
#     "id": "4630c82d-ea76-4409-a9c2-f6cb1a5c3dff",
#     "role": "player",
#     "username": "johndoe"
#   }
# }

# 4. Logout (blacklists current JWT, clears cookies)
curl -X POST http://192.168.100.8:5000/auth/logout \
  -b cookies.txt

# Expected JSON:
# {
#   "message": "Logged out successfully"
# }
