# PharmaSys repair log — 2026-10-26

## Changes made

- Product reconciliation now fetches every `/products` page (100 rows per page) rather than silently stopping at the first 100.
- Local product IDs are preserved so existing carts and local invoices keep their references; a separate `backendId` maps each local product to its server product ID.
- Local-only products are uploaded during reconciliation, while failed uploads remain in local storage instead of being discarded.
- Barcode matching now considers both `barcode` and the older local `code` field to avoid creating duplicates for seeded products.
- Pending and immediate sales resolve local product IDs to server IDs before calling the transactional `/sales` endpoint. Sales with unresolved mappings remain local and are not sent with invalid IDs.
- Product quantity updates are sent through the stock-movement endpoint as deltas; product metadata updates no longer attempt to update quantity through `PATCH /products/{id}`.
- Sale stock changes are suppressed from the generic quantity-sync wrapper because the transactional sale endpoint performs the server-side stock decrement itself. This avoids the known double-decrement path.
- Removed the separate purchase/return stock side effect from generic record sync so those stock changes are not duplicated when their local product quantity updates already create stock movements.
- Added local sale deletion for rollback if the synchronous local sale operation fails after creating an invoice.

## Tests performed

- `node --check` passed for `frontend/js/services/backendBridge.js`, `frontend/js/services/saleService.js`, and `frontend/js/storage/salesStorage.js`.
- `python -m compileall -q backend/app` passed.
- Node smoke test passed for local-to-backend product ID mapping (string ID, numeric ID, unknown ID).
- Node reconciliation smoke test passed: a local product matching a server barcode retained its local ID and gained `backendId`; a local-only product was uploaded and preserved locally; neither local product was lost.

## Remaining verification

- Live API/database integration tests were not run in this environment because the backend runtime dependencies and authenticated test server were not available here.
- Before production use, test inventory adjustments, purchases, returns, immediate sales, offline pending sales, duplicate sale retries, and failed API requests against a disposable copy of the database.
- Product creation still depends on valid backend fields and permissions. Failed uploads are logged and preserved locally for retry; they are not falsely marked as synced.


## Follow-up repairs — 2026-10-26

- Generic module sync now merges local and server records by stable ID instead of replacing the local list. Local-only records remain in the cache and are queued to the server; conflicting records use the latest `updatedAt`/`createdAt` timestamp, with local preferred when timestamps are missing or equal.
- Generic CRUD wrappers now send remote deletes for successful local delete operations and only attempt record upserts for object records with IDs. Failed sync operations preserve local data and are logged.
- Sync permission checks now require a known authenticated role and normalize role casing. Backend sync access checks normalize role casing too, preventing an unknown role from being treated as unrestricted. Existing role policy remains least-privilege.
- Cash drawer calculations subtract a return only when its refund method is cash; return records persist the original sale payment method as the default refund method.
- Purchase and return workflows now roll back local quantity changes, movement rows, and the local invoice/return if an item is missing or a later local step fails. Missing products no longer silently produce incomplete returns.
- Added rollback deletion helpers for local purchase records, return records, and inventory movements.

## Follow-up tests performed

- `node --check` passed for all JavaScript files in `frontend/js`.
- `python -m compileall -q backend/app` passed.
- Node smoke test passed for local/server union merge and upload of a local-only record.
- Live browser click-through and authenticated API/database integration tests remain unrun in this environment. These still need a disposable database and the project's installed backend dependencies.
