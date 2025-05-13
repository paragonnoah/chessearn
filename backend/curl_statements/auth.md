
### 1. Register a New User (`/auth/register`)
- **Method**: POST
- **Payload**: JSON with `first_name`, `last_name`, `email`, `username`, `phone_number`, and `password`
- **Response**: 201 on success with user details, 400 on failure
- **Notes**: No authentication or cookies required since this creates a new user.

```bash
curl -X POST https://v2.chessearn.com/auth/register \
-H "Content-Type: application/json" \
-d '{
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "username": "johndoe",
    "phone_number": "1234567890",
    "password": "securepassword"
}'
```

### 2. Log In (`/auth/login`)
- **Method**: POST
- **Payload**: JSON with `identifier` (email, username, or phone number) and `password`
- **Response**: 200 on success with user details, sets `access_token_cookie` and `refresh_token_cookie` (along with CSRF tokens), 401 on invalid credentials
- **Notes**: Cookies are saved to a file (`cookies.txt`) for use in subsequent requests.

```bash
curl -X POST https://v2.chessearn.com/auth/login \
-H "Content-Type: application/json" \
-d '{
    "identifier": "shamaria",
    "password": "AlphonsoChampe"
}' \
-c cookies.txt
```

After this request, `cookies.txt` will contain the `access_token_cookie`, `refresh_token_cookie`, `csrf_access_token`, and `csrf_refresh_token`.

### 3. Refresh Access Token (`/auth/refresh`)
- **Method**: POST
- **Requirements**: Valid refresh token in `refresh_token_cookie`, `X-CSRF-TOKEN` header with value from `csrf_refresh_token` cookie
- **Response**: 200 on success with user details and a new `access_token_cookie`, 401 on invalid refresh token
- **Notes**: Uses cookies from the login step. The CSRF token must be extracted from `cookies.txt`.

First, extract the `csrf_refresh_token`:
```bash
CSRF_REFRESH_TOKEN=$(awk '/csrf_refresh_token/ {print $7}' cookies.txt)
```

Then, perform the refresh:
```bash
curl -X POST https://v2.chessearn.com/auth/refresh \
-H "X-CSRF-TOKEN: $CSRF_REFRESH_TOKEN" \
-b cookies.txt \
-c cookies.txt
```

- `-b cookies.txt`: Sends existing cookies (including the refresh token).
- `-c cookies.txt`: Updates the cookie file with the new access token.

### 4. Log Out (`/auth/logout`)
- **Method**: POST
- **Requirements**: Valid access token in `access_token_cookie`, `X-CSRF-TOKEN` header with value from `csrf_access_token` cookie
- **Response**: 200 on success with a message, clears JWT cookies
- **Notes**: Uses cookies from the login or refresh step. The CSRF token must be extracted from `cookies.txt`.

First, extract the `csrf_access_token`:
```bash
CSRF_ACCESS_TOKEN=$(awk '/csrf_access_token/ {print $7}' cookies.txt)
```

Then, perform the logout:
```bash
curl -X POST https://v2.chessearn.com/auth/logout \
-H "X-CSRF-TOKEN: $CSRF_ACCESS_TOKEN" \
-b cookies.txt \
-c cookies.txt
```

### Additional Notes
- **CSRF Protection**: The `/refresh` and `/logout` endpoints require the `X-CSRF-TOKEN` header because they are POST requests protected by Flask-JWT-Extended with cookie-based tokens. The CSRF tokens (`csrf_refresh_token` for refresh, `csrf_access_token` for logout) are set during login and must be extracted from the cookie file.
- **Cookie Management**: The `-c` flag saves cookies, and `-b` sends them. Ensure `cookies.txt` is properly managed between requests.
- **Assumptions**: The server runs on `v2.chessearn.com`, and CSRF protection is enabled in the Flask-JWT-Extended configuration (common default when using cookies).

These `curl` statements should work with the provided authentication endpoints, assuming a standard Flask-JWT-Extended setup. Let me know if you need further clarification!

