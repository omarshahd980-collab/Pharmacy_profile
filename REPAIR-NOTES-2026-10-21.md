# PharmaSys repair notes — 2026-10-21

## Changes made
- Loaded `frontend/css/true-light-rtl-fix.css` last in `frontend/index.html` with a cache-busting version so the existing RTL/light-theme overrides actually apply.
- Improved Arabic product-name extraction in `backend/chatbot.py`, including phrases such as “هل يوجد دواء اسمه باراسيتامول؟”. Clear product lookup requests now return a specific not-found response instead of falling through to generic medical guidance.
- Added a cautious educational response for questions asking about severe-allergy symptoms and broadened severe-allergy red-flag matching to account for the Arabic definite article.
- Updated `frontend/js/services/backendBridge.js` to read the signed-in role and skip generic sync modules that the backend does not permit for that role. Backend authorization rules were not loosened.

## Validation
- `python -m py_compile` passed for `backend/chatbot.py` and `backend/app/main.py`.
- `node --check` passed for `frontend/js/services/backendBridge.js`.
- Full API/database integration tests were not run in this environment because the backend runtime dependencies/database are not configured here. Re-test against the local running server before replacing the working copy.

## Important
- Keep your original folder/ZIP as a backup. Extract this ZIP into a new folder and run it there first.
- This package contains `frontend/index.html`; it does not include `frontend/pharmasys-standalone.html`. If you launch the standalone HTML file from a different copy, its styling will not be affected by this package's CSS-link fix.
- No cashier permissions were expanded. The backend remains responsible for enforcing access control.
