# PharmaSys comprehensive repair log — 2026-10-26

This patch implements code changes for the 20 findings listed in the external comprehensive static audit. The source archive is based on `PharmaSys-Client-Ready-FOUR-MORE-FIXES-2026-10-26.zip`.

## Repairs applied

1. **Docker module packaging:** Dockerfile now copies `chatbot.py` and `prescription_scanner.py` next to `app/`.
2. **Docker API routing:** Nginx proxies the root-level API routes actually called by the frontend; port 3000 uses same-origin API calls while other local dev ports continue targeting port 8000.
3. **Prescription uploads:** Nginx request size is raised to 12 MB; Docker installs Tesseract and Arabic/English OCR data.
4. **Sale confirmation:** POS awaits server response before marking a sale as server-synced; failed requests remain in a durable local pending queue and do not open the success modal.
5. **Branch stock:** Sale, stock changes, returns, and cancellations update the main branch stock row together with the product total.
6. **Domain returns/cancellations:** Added backend-native endpoints and database records for return/cancellation status, returned quantities, and stock movements.
7. **Return idempotency:** Operation IDs are random client IDs, scoped to the authenticated user on the server, hashed to bounded storage keys, and paired with request fingerprints.
8. **Cashier stock authorization:** Cashiers are blocked from the generic stock-batch endpoint; their returns/cancellations must reference a persisted sale and valid returnable quantities.
9. **Batch idempotency:** Batch stock operations are user-scoped and reject reuse of an operation key with a different payload.
10. **Transfer concurrency:** Approval locks the transfer, affected products, and branch-stock rows on databases that support row locks; stock changes remain in one transaction.
11. **Generic sync primary-key collisions:** Generic record IDs are namespaced by user and module.
12. **Ambiguous network failures:** Pending return/cancellation operations retain their operation ID and are retried idempotently during reconciliation.
13. **Read authorization:** Sales, inventory movements, reports, branch stock, procurement, product timeline, and advanced alerts have role restrictions.
14. **Permission alignment:** Product archive/delete now allows the same admin/pharmacist roles as the frontend.
15. **One source of truth:** Sales and returns no longer sync as generic JSON records; normalized domain endpoints are used instead.
16. **Database path:** `.env.example` no longer silently selects a second relative SQLite database path. The default remains the project-root database path.
17. **Enterprise seed visibility:** Startup seed errors are logged and re-raised instead of silently ignored. Compatibility timestamp migrations use a type accepted by SQLite and PostgreSQL.
18. **Developer DB hygiene:** The empty developer SQLite database is omitted from the release archive and Docker context.
19. **Build artifact hygiene:** Python bytecode and cache directories are removed from the release archive and excluded from Docker context.
20. **Placeholder/functional QA:** Placeholder messaging now explicitly states that an inactive feature will not perform an action. A full browser-level audit of every visible control remains a required acceptance test; static checks cannot certify all buttons.

## Validation performed

- `node --check` passed for all frontend JavaScript files.
- `python -m compileall` passed for backend Python modules.
- SQLAlchemy created the revised schema and return relationships in a disposable SQLite database.
- HTML local asset references resolved; no missing local script/style references were found.
- Nginx configuration syntax passed after replacing the Docker-only `api` DNS name with a local test address for the standalone syntax check.
- Packaged database and Python cache artifacts were excluded.

## Not yet verified at runtime

The FastAPI application could not be imported in the audit environment because `python-jose` is not installed there. The dependency is declared in `backend/requirements.txt`; this environment limitation does not prove the project dependency list is incomplete. Docker is not installed in this environment, so a real image build was not performed. PostgreSQL concurrency, authenticated API integration, browser E2E flows, and the complete visible-control checklist still need to be run with the project environment and test database before production acceptance.
