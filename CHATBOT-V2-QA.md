# Chatbot v2 QA

## Static checks
- Python syntax: PASS (`backend/chatbot.py`, `backend/app/main.py`, `backend/app/models.py`, `backend/app/security.py`)
- JavaScript syntax: PASS (`frontend/js/services/backendApi.js`, `frontend/js/components/assistant.js`)
- Frontend -> Backend route: PASS (`POST /chatbot/query`)
- Production API routing: PASS (`/api/` -> FastAPI through Nginx)
- Authorization header forwarding: PASS
- Backend-first clinical flow: PASS

## Runtime note
A live FastAPI smoke test could not be completed in this analysis environment because the environment does not have the project's Python dependencies installed and external package installation is unavailable. The project `requirements.txt` remains the installation source of truth.

## Required acceptance tests on the target machine
1. Login and confirm a token exists.
2. Ask `اهلا` -> `intent=greeting`.
3. Ask for a known medicine by name -> real inventory result.
4. Ask `متى أذهب للطوارئ؟` -> emergency guidance.
5. Ask `عندي ضيق نفس` -> `safety_level=emergency`.
6. Ask for a personal dose -> refusal/safe guidance, no invented dose.
7. Stop FastAPI -> frontend should show a clear backend-unavailable message instead of freezing.
8. Start Docker stack -> frontend `/api` requests reach FastAPI and authentication works.
