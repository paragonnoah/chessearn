Base URL: https://v2.chessearn.com
    Authentication:
        The app uses cookie-based authentication with an access_token_cookie and a CSRF token (X-CSRF-TOKEN).
        The server should set cookies (access_token_cookie and csrf_access_token) in the response headers for register and login endpoints.
    Timeouts: All requests have a 30-second timeout. Ensure the server responds within this timeframe.
    Error Handling: The app expects meaningful error messages in the response body for non-200 status codes.

API Endpoints
1. Register a New User

    Endpoint: POST /auth/register
    Description: Registers a new user with personal details such as first name, last name, email, username, phone number, and password.
    Headers: Content-Type: application/json
    Body: JSON object with first_name, last_name, email, username, phone_number, and password.
    Expected Response: Should return a success status (e.g., 201) and set access_token_cookie and csrf_access_token cookies in the response headers.
    cURL Command:
    bash

    curl -X POST https://v2.chessearn.com/auth/register \
      -H "Content-Type: application/json" \
      -d '{"first_name": "John", "last_name": "Doe", "email": "john.doe@example.com", "username": "johndoe", "phone_number": "+1234567890", "password": "securepassword123"}'

2. Login

    Endpoint: POST /auth/login
    Description: Logs in a user using an identifier (e.g., email or username) and password. Returns user details and sets authentication cookies.
    Headers: Content-Type: application/json
    Body: JSON object with identifier and password.
    Expected Response: Should return a 200 status code with a JSON response containing a id field, and set access_token_cookie and csrf_access_token cookies in the response headers.
    cURL Command:
    bash

    curl -X POST https://v2.chessearn.com/auth/login \
      -H "Content-Type: application/json" \
      -d '{"identifier": "john.doe@example.com", "password": "securepassword123"}'

3. Logout

    Endpoint: POST /auth/logout
    Description: Logs out the current user by invalidating the session.
    Headers:
        X-CSRF-TOKEN: CSRF token stored in _csrfToken.
        Cookie: access_token_cookie with the access token.
    Expected Response: Should return a 200 status code on success.
    Notes: Requires authentication via cookies and CSRF token.
    cURL Command:
    bash

    curl -X POST https://v2.chessearn.com/auth/logout \
      -H "X-CSRF-TOKEN: your_csrf_token_here" \
      -H "Cookie: access_token_cookie=your_access_token_here"

4. Get User Profile

    Endpoint: GET /profile
    Description: Retrieves the user’s profile information.
    Headers:
        Cookie: access_token_cookie with the access token.
    Expected Response: Should return a 200 status code with the user’s profile data in JSON format.
    Notes: Requires authentication via cookies.
    cURL Command:
    bash

    curl -X GET https://v2.chessearn.com/profile \
      -H "Cookie: access_token_cookie=your_access_token_here"

5. Upload Profile Photo

    Endpoint: POST /profile/photo
    Description: Uploads a profile photo for the user.
    Headers:
        X-CSRF-TOKEN: CSRF token stored in _csrfToken.
        Cookie: access_token_cookie with the access token.
    Body: Multipart form data with a photo field.
    Expected Response: Should return a 200 status code on success.
    Notes: Requires authentication via cookies and CSRF token.
    cURL Command:
    bash

    curl -X POST https://v2.chessearn.com/profile/photo \
      -H "X-CSRF-TOKEN: your_csrf_token_here" \
      -H "Cookie: access_token_cookie=your_access_token_here" \
      -F "photo=@/path/to/your/photo.jpg"

6. Post Game Move

    Endpoint: POST /game/move
    Description: Submits a chess move in a game.
    Headers:
        Content-Type: application/json
        X-CSRF-TOKEN: CSRF token stored in _csrfToken.
        Cookie: access_token_cookie with the access token.
    Body: JSON object with move (e.g., "e4").
    Expected Response: Should return a 200 status code on success.
    Notes: Requires authentication via cookies and CSRF token.
    cURL Command:
    bash

    curl -X POST https://v2.chessearn.com/game/move \
      -H "Content-Type: application/json" \
      -H "X-CSRF-TOKEN: your_csrf_token_here" \
      -H "Cookie: access_token_cookie=your_access_token_here" \
      -d '{"move": "e4"}'

7. Get Wallet Balance

    Endpoint: GET /wallet
    Description: Retrieves the user’s wallet balance.
    Headers:
        Cookie: access_token_cookie with the access token.
    Expected Response: Should return a 200 status code with a JSON object containing country and balance fields.
    Notes: Requires authentication via cookies.
    cURL Command:
    bash

    curl -X GET https://v2.chessearn.com/wallet \
      -H "Cookie: access_token_cookie=your_access_token_here"

8. Search Users

    Endpoint: GET /users/search
    Description: Searches for users based on a query string.
    Query Parameters: query (search term).
    Headers:
        Cookie: access_token_cookie with the access token.
    Expected Response: Should return a 200 status code with a JSON array of user objects.
    Notes: Requires authentication via cookies.
    cURL Command:
    bash

    curl -X GET "https://v2.chessearn.com/users/search?query=johndoe" \
      -H "Cookie: access_token_cookie=your_access_token_here"

9. Send Friend Request

    Endpoint: POST /friends/request
    Description: Sends a friend request from one user to another.
    Headers:
        Content-Type: application/json
        X-CSRF-TOKEN: CSRF token stored in _csrfToken.
        Cookie: access_token_cookie with the access token.
    Body: JSON object with userId and friendId.
    Expected Response: Should return a 200 status code on success.
    Notes: Requires authentication via cookies and CSRF token.
    cURL Command:
    bash

    curl -X POST https://v2.chessearn.com/friends/request \
      -H "Content-Type: application/json" \
      -H "X-CSRF-TOKEN: your_csrf_token_here" \
      -H "Cookie: access_token_cookie=your_access_token_here" \
      -d '{"userId": "user123", "friendId": "friend456"}'

10. Deposit Funds

    Endpoint: POST /wallet/deposit
    Description: Deposits funds into the user’s wallet.
    Headers:
        Content-Type: application/json
        X-CSRF-TOKEN: CSRF token stored in _csrfToken.
        Cookie: access_token_cookie with the access token.
    Body: JSON object with userId and amount.
    Expected Response: Should return a 200 status code on success.
    Notes: Requires authentication via cookies and CSRF token.
    cURL Command:
    bash

    curl -X POST https://v2.chessearn.com/wallet/deposit \
      -H "Content-Type: application/json" \
      -H "X-CSRF-TOKEN: your_csrf_token_here" \
      -H "Cookie: access_token_cookie=your_access_token_here" \
      -d '{"userId": "user123", "amount": 50.0}'

11. Withdraw Funds

    Endpoint: POST /wallet/withdraw
    Description: Withdraws funds from the user’s wallet.
    Headers:
        Content-Type: application/json
        X-CSRF-TOKEN: CSRF token stored in _csrfToken.
        Cookie: access_token_cookie with the access token.
    Body: JSON object with userId and amount.
    Expected Response: Should return a 200 status code on success.
    Notes: Requires authentication via cookies and CSRF token.
    cURL Command:
    bash

    curl -X POST https://v2.chessearn.com/wallet/withdraw \
      -H "Content-Type: application/json" \
      -H "X-CSRF-TOKEN: your_csrf_token_here" \
      -H "Cookie: access_token_cookie=your_access_token_here" \
      -d '{"userId": "user123", "amount": 20.0}'

Additional Developer Notes

    Authentication Tokens: The app expects the server to set access_token_cookie and csrf_access_token cookies in the response headers for register and login. These tokens should be validated for subsequent authenticated requests.
    CSRF Protection: The X-CSRF-TOKEN header is included in requests requiring authentication to prevent cross-site request forgery. Ensure the server validates this token.
    Response Formats:
        login: Should include a JSON response with an id field.
        getWalletBalance: Should return a JSON object with country and balance fields.
        searchUsers: Should return a JSON array of user objects.
    Error Handling: Return appropriate HTTP status codes (e.g., 400 for bad requests, 401 for unauthorized, 500 for server errors) with descriptive JSON error messages.
    Timeout Consideration: Design the API to respond within 30 seconds to avoid client-side timeouts.

This documentation should guide the backend developer in implementing the API endpoints to match the behavior of your ApiService class. Let me know if you need further refinements or additional endpoints!