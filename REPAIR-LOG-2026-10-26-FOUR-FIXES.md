# PharmaSys — Four additional fixes (2026-10-26)

## Changes
1. Inventory adjustment now resolves the server product ID through `BackendBridge.backendProductId`, writes one stock movement to the dedicated API first, then updates local quantity with automatic quantity-sync suppression. It does not show a server-success message before the API succeeds.
2. Added atomic `POST /inventory/stock-batch` for return/cancellation stock-in movements. It validates all products before committing, updates branch stock and movement ledger in one transaction, and records an operation key in `sync_records` to make repeat requests idempotent.
3. Cashier access to the batch endpoint is restricted to stock-in movements with `Return #...` or `Invoice Cancellation #...` notes. Manual stock adjustments remain admin/pharmacist-only on the existing endpoint.
4. Return and invoice-cancellation flows now await the batch API when authenticated, suppress duplicate per-product stock synchronization, roll back local quantities/movements/return records when the batch fails, and show success only after server confirmation. UI handlers await the async service results.

## Validation performed
- `node --check` passed for every frontend JavaScript file.
- `python -m compileall` passed for backend/app.
- Static checks confirmed the duplicate inventory stock call was removed, backend ID mapping is used, the batch endpoint/client method exist, and the UI awaits return/cancellation.

## Remaining validation
The full API/runtime flow was not executed against a running FastAPI server/database in this environment. Verify the stock batch endpoint and return/cancellation workflow against a disposable test database before production use. Local browser storage and server database cannot be a single distributed transaction; the code rolls back local changes on a reported server failure, but a lost network response after a successful server commit still requires retrying with the same operation ID to receive the idempotent result.
