# PharmaSys ROUND8 — Repairs and QA report
Date: 2026-10-26
Base: ROUND7 source archive

## Code changes applied

1. **Sale rejection stock bug:** An immediate HTTP 4xx rejection happens before the sale service's local stock decrement. The prior code incorrectly added the sold quantity to local stock in that branch. Removed that reversal. The invoice remains marked `rejected` and is excluded from retries. The later pending-reconciliation 4xx path still reverses local stock because that path is only reached after an ambiguous network/5xx result and local stock was already decremented.
2. **Category normalization:** The create-category pre-check now compares `lower(trim(name))`, matching the database unique index expression.
3. **Legacy duplicate category remediation:** Added `backend/scripts/repair_legacy_categories.py`. It is dry-run by default. With `--apply --backup-confirmed`, it merges only names equal after lowercase/trim, reassigns product category references to the lowest-ID category, preserves distinct non-empty descriptions, removes duplicate category rows in one transaction, and creates the unique index. Never run `--apply` without a verified backup.
4. **Unknown frontend routes:** Invalid hash routes normalize to `#/dashboard` instead of rendering dashboard content under a broken URL.
5. **Docker maintenance access:** The category repair script is included in the backend image for controlled database maintenance.

## Checks completed

- `python -m compileall -q backend/app backend/scripts backend/chatbot.py backend/prescription_scanner.py`: PASS.
- `node --check` on every frontend JavaScript file: PASS.
- `node --check` on backend JavaScript files: PASS.
- Disposable SQLite schema creation and repeated compatibility migration: PASS.
- Legacy category migration test: PASS (dry-run, apply, category merge, product reference preservation, descriptions, unique index).
- Static regression assertions for sale rejection stock behavior, category normalization, ownerless sync access, and unknown route normalization: PASS.
- ROUND7 ZIP integrity: PASS before packaging.

## Still not verified (do not describe as production-certified)

- FastAPI authentication/API integration with actual `python-jose`, `passlib`, and `bcrypt`: blocked because those packages are missing in this environment.
- Docker build/compose startup and Nginx API/upload behavior: Docker executable is unavailable here.
- Browser end-to-end test of all visible controls and all roles.
- PostgreSQL concurrent sales/stock/transfer/return tests.
- A migration run against a copy of the user's actual existing database. The new category repair script must be reviewed in dry-run mode against that database first.

## Safe legacy-category repair

From `backend/` after backing up the database and confirming `DATABASE_URL` points to the intended copy:

```powershell
python scripts/repair_legacy_categories.py
python scripts/repair_legacy_categories.py --apply --backup-confirmed
```

The first command only reports duplicates. Review its output before running the second command. Do not run the apply command against a live production database without a verified backup and maintenance window.
