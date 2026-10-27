# PharmaSys Repair Log — Round 3 (2026-10-26)

## Fixed

1. **Purchases are now backend-first.** Added `POST /purchases` with server-side validation and transactional updates for product quantity, MAIN branch stock, stock movements, and purchase price history. The frontend waits for the backend before applying local stock changes. It requires a confirmed `backendId` for each product instead of assuming local IDs match server IDs, and suppresses the generic bridge's quantity sync to avoid double stock increments.
2. **Purchase idempotency.** Purchase number is scoped to the authenticated user; the backend stores a payload hash and returns the original result for an identical retry, or `409` for reuse with different contents. Concurrent uniqueness collisions are reconciled after rollback.
3. **Concurrent sale/return/cancel idempotency.** Integrity conflicts now re-read the persisted operation and return the existing result only when the stored request hash matches; a conflicting payload returns `409`. Return/cancel creation flushes were moved inside their transaction handlers so integrity conflicts are handled.
4. **Delivery duplicate protection.** A sale cannot receive a second non-cancelled/non-failed delivery order. Fully returned invoices are rejected. Cancelled/failed orders can be retried under the current business rule.
5. **Delivery state machine.** Status transitions are explicitly constrained; delivered/cancelled orders cannot be reassigned. Driver-role updates remain limited to delivery progress.
6. **Backward-compatible purchase-history schema.** Added idempotent compatibility columns/index for `purchase_price_history` so older databases can run the purchase endpoint.

## Validation performed

- `python -m compileall` on backend: passed.
- `node --check` on all frontend JS files: passed.
- Pydantic `PurchaseCreate` validation smoke test: passed.
- Fresh SQLite schema creation + compatibility migration smoke test: passed.

## Not completed / limitations

- Full HTTP API integration tests were not run because the environment lacks `python-jose`; runtime import of `app.main` fails with `ModuleNotFoundError: jose`.
- Docker/PostgreSQL and browser workflows were not run.
- Purchases require products to have a confirmed backend mapping and the authenticated user to have admin/pharmacist role. The frontend intentionally fails closed instead of writing a purchase only to local storage.
- Delivery duplicate check is guarded in application logic; production should also be tested under concurrent requests on the target database before go-live.
