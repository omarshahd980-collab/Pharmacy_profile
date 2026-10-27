# PharmaSys — Round 2 Repair Log (2026-10-26)

## Implemented

1. **Sale idempotency:** stores a canonical request hash and rejects reuse of a client reference with a different payload using HTTP 409. A legacy invoice with a reference but no saved hash is not silently reused.
2. **Branch-aware sales:** `SaleCreate` accepts an optional `branch_id` (defaults to active MAIN branch); stock is validated and decremented from that branch. `Product.quantity` remains the MAIN-branch balance only. Returns and cancellations restore stock to the invoice's originating branch, and change `Product.quantity` only for MAIN.
3. **Delivery totals:** removed client-supplied `items_total` from the schema. Delivery items are product IDs and quantities; prices are recalculated from active products, or taken from a persisted sale when `sale_id` is supplied. Invalid/cancelled invoices are rejected. Added the missing `DeliveryOrder.sale_id` ORM field and compatibility migration, fixing a runtime constructor error in delivery creation.
4. **Production configuration:** setup script defaults to `NODE_ENV=production`; both Compose configurations explicitly set production mode. Production disables `/docs`, `/redoc`, and `/openapi.json`, requires a configured strong secret/bootstrap password, and does not create demo users. Existing demo accounts still using `demo1234` are disabled on production startup; accounts with changed credentials are not automatically disabled.
5. **Archived barcode reuse:** archiving a product preserves the old value in `archived_barcode` and clears the unique active barcode, allowing it to be reused. Added a compatibility migration for existing databases.
6. **Schema compatibility:** added migration columns for `sales.request_hash`, `sales.branch_id`, `products.archived_barcode`, and `delivery_orders.sale_id`.

## Validation performed

- Python `compileall`: passed.
- `node --check` for all frontend JavaScript files: passed.
- Pydantic schema tests: rejected empty/null required product fields and unsupported payment methods; accepted supported cash/card; accepted delivery item aliases.
- SQLite schema creation and repeat migration: passed.
- Direct database-backed route-function integration checks: branch B2 sale reduced only B2 stock; MAIN stock remained unchanged; identical idempotent retry returned the original invoice; conflicting key payload returned 409; return/cancellation restored B2 stock correctly; delivery totals were calculated server-side; invalid sale ID returned 404.

## Limits

- The sandbox does not have `python-jose` or `passlib`, and network access prevented installing them. For direct route-function checks only, auth primitives were stubbed; this is **not** a full HTTP/TestClient/authentication test.
- Docker/PostgreSQL and Windows `.bat`/`.ps1` execution were not run here.
- For production deployment, back up the database first, review `.env` values, set a unique `SECRET_KEY` and `BOOTSTRAP_PASSWORD`, and verify the generated initial admin credentials before handing the system to a customer.
