# PharmaSys — Production Checklist

1. Copy `deploy/.env.example` to your deployment environment and set strong secrets.
2. Run from the project root:
   `docker compose -f deploy/docker-compose.yml up -d --build`
3. Open `http://localhost:3000`.
4. API docs: `http://localhost:8000/docs`.
5. Default development accounts are seeded only when the database is empty. Change `BOOTSTRAP_PASSWORD` before production.
6. For real production, put HTTPS/TLS in front of nginx and use a strong PostgreSQL password and `SECRET_KEY`.

The frontend currently defaults to port 8000 for API calls. For a reverse-proxy deployment, set `window.PHARMASYS_API_URL` to the public API URL before `backendApi.js`, or change the runtime config to `/api` and proxy that path to the API container.
