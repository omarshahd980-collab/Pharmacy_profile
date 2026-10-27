# PharmaSys — Security Integration Report

## What was fixed

### Authentication
- Replaced the old stateless FastAPI JWT with short-lived access tokens bound to server-side sessions.
- Added 30-day refresh tokens with rotation and reuse detection.
- Reusing an old refresh token revokes all sessions for that user.
- Disabled/inactive users are rejected immediately.
- Added login throttling and account lockout after repeated failures.
- Password changes revoke all active sessions.

### Authorization
- Server-side role checks remain authoritative.
- The browser cannot elevate its role by editing LocalStorage; protected API routes validate the authenticated database user.
- Sensitive admin/audit endpoints remain server-protected.

### API hardening
- Request bodies are limited to 256 KB.
- CORS methods/headers are restricted.
- Security response headers are applied centrally.
- Production requires a 32+ character `SECRET_KEY`.
- Production requires `BOOTSTRAP_PASSWORD`.
- Backend is no longer directly published by Docker; nginx is the public entry point.

### Data integrity
- Sales lock product rows before stock checks/decrements.
- Sale processing rolls back on failure.
- Client references remain idempotent for repeated sale submissions.

### Frontend integration
- Login now stores the access + refresh session returned by the real backend.
- API requests automatically refresh an expired access token once.
- Startup validates the backend session before rendering the application.
- Offline authentication is explicitly demo-only and cannot be silently enabled by the backend.

### Cleanup
- Removed the obsolete `backend/security_enhanced.py`, which contained a hard-coded fallback secret and duplicated authentication logic.
- The standalone Node/Express security package is not used as a second backend; its controls were merged into the actual FastAPI backend to avoid two competing authentication systems.

## Remaining recommendation

The current frontend stores its access token in browser storage because the existing application contract is built around a bearer token. For a higher-security internet-facing deployment, the next step should be moving refresh/session handling to Secure + HttpOnly cookies and keeping the access token in memory.

## Verification performed

- Python backend source compiled successfully with `compileall`.
- All modified JavaScript files passed `node --check`.
- Existing SQLite database was inspected and contains zero users, so the hardened bootstrap path can initialize it cleanly.
