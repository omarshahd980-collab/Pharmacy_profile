# PharmaSys — Round 4 Repair Log

Date: 2026-10-26
Base: `PharmaSys-Client-Ready-ROUND3-PURCHASE-DELIVERY-IDEMPOTENCY-FIXES-2026-10-26.zip`

## Changes made

1. **Discount-aware returns and cancellations**
   - Return amounts are now calculated from each invoice line's net amount after allocating the invoice discount proportionally.
   - Partial returns calculate the incremental rounded refund so repeated partial returns do not repeatedly refund the full line amount.
   - Cancellation refunds only the remaining net amount after previous partial returns.

2. **Expired-product sale guard**
   - `POST /sales` rejects products whose expiry date is earlier than the server's current date. This is a backend check, not only a UI warning.

3. **Partially returned invoice delivery**
   - Delivery creation for an invoice now includes only quantities that have not already been returned.
   - Delivery item totals are allocated from the net invoiced line amount after discounts.
   - Fully cancelled/returned invoices and invoices with no remaining quantities are rejected.

4. **Purchase price guard**
   - Purchase receiving rejects a unit purchase price higher than the current selling price with HTTP 409. This conservative rule prevents silently receiving stock at a negative margin; businesses that intentionally accept loss-leading purchases need an explicit approval/override workflow before enabling that use case.

5. **Purchase UI recovery after server commit**
   - If the server has committed a purchase but a subsequent local UI/cache update fails, the UI no longer deletes the local invoice as if the server transaction had failed. It warns the user to refresh/re-sync before retrying, reducing duplicate receiving risk.

6. **Concurrent delivery protection**
   - Added nullable unique `active_sale_id` to claim one active delivery per invoice at the database level.
   - The compatibility migration adds the column and unique index.
   - Creating a duplicate active claim returns HTTP 409 rather than an unhandled integrity error.
   - Cancelled/failed deliveries release the claim; transitions back to active states must reacquire it and return HTTP 409 if another order owns it.

7. **Concurrent stock-transfer approval**
   - Transfer approval conditionally changes the transfer from `pending` to `completed` within the same transaction before stock movements. A competing approval cannot successfully claim the same pending transfer.

## Validation performed

- `python -m compileall -q backend`: passed.
- `node --check` for every `frontend/js/**/*.js`: passed.
- Fresh SQLite schema creation and compatibility migration, including unique `active_sale_id` index: passed.
- ZIP integrity check: passed.
- Discount-allocation arithmetic spot-checks: passed.

## Not verified end-to-end

- Full authenticated HTTP API run was not possible in this environment because `python-jose` and `passlib` are not installed.
- PostgreSQL, Docker, Windows `.bat`/`.ps1`, and full browser workflows were not run.
- Existing production database backup/migration has not been run. Back up the database before opening the new build. The migration intentionally does not automatically assign `active_sale_id` to legacy orders; the API's existing duplicate query still checks existing non-cancelled/non-failed orders.
- The purchase-price guard may reject a legitimate loss-leading purchase. If the business needs that case, add an explicit permissioned override with an audit record rather than removing the guard silently.
