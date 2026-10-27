# PharmaSys API 2.0

FastAPI backend for the PharmaSys pharmacy management UI.

## Highlights
- JWT authentication with bcrypt password hashing.
- CORS configured from environment, without wildcard credentials.
- Products, categories, barcode lookup, stock movements and sales are transactional.
- Server-side persistence endpoints for the remaining frontend modules so LocalStorage is an offline cache, not the only database.
- Development bootstrap users on an empty local database; existing credentials/roles are preserved on restart, and well-known demo accounts are not created in production.

## Run
```bash
python -m venv .venv
# activate the environment
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Use `.env.example` as the starting point for environment variables.

## Delivery module
- `delivery` is a dedicated user role.
- Admin/pharmacist/cashier can create and assign delivery orders.
- Delivery drivers can only list/update orders assigned to their own account.
- Driver updates are limited to `out_for_delivery`, `delivered`, and `failed`.
- Delivery endpoints: `GET /delivery/orders`, `POST /delivery/orders`, `PATCH /delivery/orders/{order_id}`.


## Security hardening
- Access JWTs expire after 15 minutes by default and are bound to a server-side session.
- Refresh tokens rotate on every refresh; reuse detection revokes all sessions.
- Failed-login lockout and IP-based login throttling are enabled.
- Password changes revoke all active sessions.
- Disabled users are rejected immediately because every authenticated request checks the server-side session and account status.
- Sales lock product rows before stock checks/decrements to prevent concurrent overselling.
- Request bodies are limited to 256 KB and security headers are added centrally.
- Never use the development secret or demo bootstrap password in production. Production first startup requires a unique `BOOTSTRAP_PASSWORD` of at least 12 characters; only the admin account is bootstrapped there.

## Prescription OCR requirements (Windows)

The Python OCR packages are installed from `requirements.txt` (`opencv-python-headless`, `numpy`, and `pytesseract`). `pytesseract` also requires the **Tesseract OCR application** to be installed separately. For Arabic and English prescriptions, install Tesseract with both `ara` and `eng` language data and ensure `tesseract.exe` is on `PATH`. If it is installed in a custom location, set `pytesseract.pytesseract.tesseract_cmd` in `prescription_scanner.py` to that verified path. Restart the backend after installing it.

The scan endpoint accepts image uploads up to 10 MiB. OCR output and medicine matches are assistive only: verify every detected medicine against the original prescription; OCR is not a substitute for pharmacist review.
