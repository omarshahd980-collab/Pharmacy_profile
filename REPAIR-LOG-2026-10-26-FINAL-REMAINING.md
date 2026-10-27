# PharmaSys — Final Remaining-Issue Repairs

Date: 2026-10-26
Base archive: `PharmaSys-Client-Ready-COMPREHENSIVE-REPAIRS-2026-10-26.zip`

## Repairs applied

1. **Definitive sale API rejection** (`frontend/js/services/saleService.js`)
   - Missing backend product mapping is now treated as a permanent data error, not queued as offline.
   - HTTP 4xx errors (validation, permission, insufficient stock, conflict) delete the just-created local invoice and return before local stock is decremented.
   - Network failures and server-side 5xx remain pending because the result can be ambiguous; retries retain the same client reference for server idempotency.

2. **Concurrent stock mutation** (`backend/app/main.py`)
   - The manual stock endpoint locks the product row with `FOR UPDATE`, locks the MAIN branch-stock row when present, updates product/branch/movement in one transaction, refreshes the response, and rolls back on every exception.
   - The stock-batch path now also locks existing branch-stock rows.

3. **Return/cancellation idempotency fingerprint** (`backend/app/main.py`)
   - Fingerprints now include both the target `sale_id` and request payload.
   - Reusing an operation key for another invoice or a different payload returns HTTP 409.
   - Legacy fingerprints remain accepted only for the same existing invoice to avoid breaking retries created before this patch.

4. **Migration ledger** (`backend/app/database.py`)
   - Added a `schema_migrations` table and an idempotent version marker for the existing compatibility-column migration.
   - This is a lightweight forward-compatibility ledger, not a substitute for a full Alembic migration suite. Back up real customer databases and test their upgrade before production deployment.

5. **Visible placeholder features**
   - The generic placeholder screen explicitly labels those pages as not yet implemented. They are not silently treated as successful actions. Each visible placeholder still needs a product decision: implement it or remove/disable its navigation entry before customer release.

## Validation performed

- All frontend JavaScript files pass `node --check`.
- Backend Python files pass `python -m compileall`.
- A disposable SQLite database creates all ORM tables, runs the compatibility migration twice, and contains the expected migration version marker.
- Static assertions verify the sale rejection path, stock row locking, and sale-scoped idempotency fingerprints.
- ZIP integrity check passes.

## Not verified in this environment

- Authenticated FastAPI endpoint tests and full request/response flows.
- Docker image build/compose startup.
- Browser end-to-end testing of all buttons and roles.
- PostgreSQL concurrent transaction tests and upgrades of real customer databases.

Do not describe the release as production-certified until those runtime acceptance tests pass.
