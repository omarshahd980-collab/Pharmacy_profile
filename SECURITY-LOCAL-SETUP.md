# Local secure startup

Use `RUN_PHARMASYS.bat` for the easiest local startup.

On first run, the backend creates `backend/.env` automatically with a generated local JWT secret and a bootstrap admin password. The current launcher script prints the initial password once when it creates the file. Use that value with:

- Username: `admin@pharmasys.local`

Change the password after the first login. The generated JWT secret is stored only in the local `.env` file and should never be shared or committed.

Existing account passwords, roles, disabled status, and lockouts are not reset on restart. In production, only the administrator bootstrap account may be created automatically; set a unique `BOOTSTRAP_PASSWORD` of at least 12 characters before the first production startup, plus a production secret/CORS configuration. Well-known demo pharmacist/cashier/delivery accounts are not created in production.


Database compatibility fix: authentication lockout fields belong to `users`, not `products`. Existing databases are not destructively modified; legacy extra product columns, if present, are ignored.
