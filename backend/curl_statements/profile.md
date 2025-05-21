### Get Profile
using `--cookie cookies.txt` for authentication, so it remains unchanged.

```bash
curl -X GET https://v2.chessearn.com/profile \
  --cookie cookies.txt
```

**Response (example):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "username": "johndoe",
  "phone_number": "+1234567890",
  "role": "player",
  "ranking": 800,
  "wallet_balance": 0.0,
  "is_active": true,
  "is_verified": false,
  "photo_url": "https://v2.chessearn.com/profile/photo/123e4567-e89b-12d3-a456-426614174000"
}
```
 
 
 
 
 we'll use `--cookie cookies.txt` instead. Additionally, for POST requests with Flask-JWT-Extended using cookies, a CSRF token is typically required in the `X-CSRF-TOKEN` header. A`cookies` contains both `access_token_cookie` and `csrf_access_token`, you’ll need to extract the `csrf_access_token` value and include it.

```bash
curl -X POST \
  https://v2.chessearn.com/profile/photo \
  --cookie cookies.txt \
  -H "X-CSRF-TOKEN: <csrf_access_token_value>" \
  -F "photo=@profile.jpg"
```

**Response:**
```json
{"message": "Photo uploaded successfully"}
```

**Note:** Replace `<csrf_access_token_value>` with the actual `csrf_access_token` from your `cookies.txt` file (e.g., `59c9cc36-e659-4808-b7b5-1ecafdb31165`).





### Get the Photo
The original statement doesn’t use authentication, which aligns with the endpoint not requiring `@jwt_required()`. Since the photo is publicly accessible, no cookie is needed, and the command stays as is.

```bash
curl -X GET \
  https://v2.chessearn.com/profile/photo/123e4567-e89b-12d3-a456-426614174000 \
  -o photo.jpg
```

- This downloads the image to `photo.jpg`. Open it to view the uploaded photo.
- Alternatively, access the `photo_url` in a browser to display the image directly.

### Additional Notes
- **Cookies File:** Ensure `cookies.txt` is in Netscape format and includes at least `access_token_cookie` for authentication and `csrf_access_token` for POST requests. Example:
  ```
  192.168.100.8 FALSE / FALSE 0 access_token_cookie eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  192.168.100.8 FALSE / FALSE 0 csrf_access_token 59c9cc36-e659-4808-b7b5-1ecafdb31165
  ```
- **CSRF Token:** For the "Upload a Photo" command, you’ll need to manually extract the `csrf_access_token` from `cookies.txt` and insert it into the `-H "X-CSRF-TOKEN: ..."` part, as curl doesn’t automatically map cookie values to headers.

These updated statements ensure consistency in using cookies for authentication where required, aligning with your preference.

```bash
# Upload a Photo
curl -X POST \
  https://v2.chessearn.com/profile/photo \
  --cookie cookies.txt \
  -H "X-CSRF-TOKEN: <csrf_access_token_value>" \
  -F "photo=@profile.jpg"

# Get Profile
curl -X GET https://v2.chessearn.com/profile \
  --cookie cookies.txt

# Get the Photo
curl -X GET \
  https://v2.chessearn.com/profile/photo/123e4567-e89b-12d3-a456-426614174000 \
  -o photo.jpg
```


example cookie 
