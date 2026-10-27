# PharmaSys Clinical & Pharmacy Assistant v2.1

## What changed
- Backend-first chatbot: `/chatbot/query` is the source of truth for clinical/product questions.
- Arabic/Egyptian normalization and medicine-name search.
- Emergency triage with red-flag prioritization.
- Safe handling of diagnosis and dose requests; no personal prescribing.
- Product responses include stock, price, manufacturer, barcode and expiry when available.
- Frontend API calls now have timeouts and clearer offline/401 handling.
- Dynamic suggestion buttons returned by the backend are rendered in the chat.
- Production runtime continues to use same-origin `/api` behind Nginx.

## Run

### Docker production
```bash
cd deploy
docker compose up --build
```
Open `http://localhost:3000`.

### Local
```bash
cd backend
uvicorn app.main:app --reload --port 8000
```
Serve `frontend/` with a static server on port 3000/5173.

## Important clinical boundary
This assistant is a pharmacy/clinical information and triage assistant. It must not be marketed as a replacement for a physician, and it must not generate individualized diagnosis or dosing decisions without an appropriately qualified clinician and the required patient data.
