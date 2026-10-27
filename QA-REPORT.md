# PharmaSys QA / Production Hardening Report

## Automated checks completed
- Python compileall: PASS
- JavaScript syntax (`node --check`): PASS for all frontend JS files
- Backend import in package mode: PASS
- Backend import from `backend/` runtime mode: PASS (with declared dependencies available)
- Docker Compose YAML parse: PASS
- API E2E using isolated SQLite test DB: **14/14 PASS**

### E2E coverage
1. Health endpoint
2. Admin login / JWT
3. `/auth/me`
4. Product creation
5. Barcode lookup
6. Stock adjustment
7. Sale creation
8. Sale totals
9. Stock decrement after sale
10. Sale idempotency using `client_reference`
11. Cashier login
12. Cashier blocked from product creation
13. Cashier blocked from users sync
14. Cashier allowed to sync customers

## Fixes applied during QA
- Unified chatbot and prescription scanner authentication with the main JWT security module.
- Fixed backend package/runtime imports for chatbot and scanner routers.
- Made OCR dependencies lazy so the API can start without OCR packages; scanner returns HTTP 503 when OCR dependencies are unavailable.
- Added server-side RBAC checks for product/category/inventory mutation and generic module sync.
- Added per-user ownership to generic sync records.
- Added sale `client_reference` idempotency to prevent duplicate backend invoices during offline retry.
- Added pending-sale reconciliation from LocalStorage to the backend.
- Backend authentication is now required by default; local demo authentication is only available when explicitly enabled with `window.PHARMASYS_OFFLINE_AUTH = true`.
- Demo account UI is hidden unless `window.PHARMASYS_DEMO_MODE = true`.
- Added a small forward-compatible schema migration for existing SQLite/PostgreSQL databases.
- Added runtime flags for offline/demo mode.

## Not verified in this environment
- Actual Docker image build/run (Docker CLI is unavailable in the test environment).
- Real PostgreSQL container runtime.
- Browser visual/manual testing on physical Android/iOS/desktop browsers.
- OCR accuracy on real prescription images.

## Production recommendation
Before live deployment, set a strong `SECRET_KEY`, strong `POSTGRES_PASSWORD`, a unique `BOOTSTRAP_PASSWORD`, explicit `CORS_ORIGINS`, and (if OCR is needed) install the OS-level Tesseract Arabic/English language packs.

## Client release checks — 2026-10-07
- Frontend JavaScript syntax check: PASS.
- Backend Python compile check: PASS.
- Frontend HTTP smoke test on 127.0.0.1:5510: PASS.
- Local asset/script reference validation: PASS.
- Removed generated `__pycache__` / `.pyc` artifacts from the delivery package.
- Restored the Inventory route/page and sidebar entry.
- Updated the pharmacy assistant UI to use the white-coat doctor artwork.
- Updated the backend Permissions-Policy to allow camera access for same-origin barcode scanning.

The earlier backend E2E report in this file remains the reference for the API flow; a fresh backend E2E run was not repeated in this environment because `python-jose` and `passlib` are not installed here and outbound package installation is unavailable.


## Follow-up source audit — 2026-10-21

### Confirmed issues corrected
- The floating assistant in `frontend/js/components/assistant.js` never called `BackendAPI.chatbot()` and always answered from local rules. It now uses the authenticated `/chatbot/query` endpoint first, safely renders the backend reply/products/suggestions, and falls back to local analytics only when no backend session is available or the backend request fails.
- `GET /chatbot/health` required a JWT even though it returns only a non-sensitive service status/version. It is now a public health check, consistent with `/health`, so a browser/PowerShell smoke test can verify the chatbot router without logging in. `POST /chatbot/query` remains authenticated.
- The severe-allergy educational question branch ran after red-flag detection, making it unreachable for typical questions about severe-allergy symptoms. Educational questions are now handled before phrase-only triage, while explicit danger signs still trigger emergency triage.
- Fixed Arabic-normalization mismatches in red-flag patterns for speech difficulty and infant breathing difficulty.
- `ChatResponse` list defaults now use `Field(default_factory=list)`.
- Startup bootstrap previously reset standard account passwords, roles, active status, and lockout counters every time the backend started, and created known demo accounts regardless of environment. Existing accounts are now preserved on restart; production bootstrap creates only a missing admin and requires a unique `BOOTSTRAP_PASSWORD` of at least 12 characters.

### Checks run for this follow-up
- Python `compileall` / `py_compile`: PASS.
- JavaScript `node --check`: PASS for all frontend and backend JavaScript files.
- `frontend/index.html` local asset references: PASS (68 local references checked; no missing paths).
- Duplicate HTML IDs: none found in `frontend/index.html`.
- Backend integration/E2E tests: NOT RUN in this audit container because `python-jose`, `passlib`, and `psycopg` are not installed here. Run `pip install -r backend/requirements.txt` in the project's virtual environment, then repeat runtime/API tests locally.
- Browser visual testing and live authenticated chatbot tests still require the user's local browser/session.

### Important scope note
This ZIP contains `frontend/index.html`, not `frontend/pharmasys-standalone.html`. Use the included project folder's normal launcher/entry point to test these changes; a different standalone HTML copy will not receive them.
