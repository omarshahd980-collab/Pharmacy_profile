# Remaining PharmaSys Acceptance Matrix

| Area | Current code-level status | Required runtime acceptance |
|---|---|---|
| Sale rejected for insufficient stock | Local invoice cleanup path added for HTTP 4xx | Confirm no local invoice, no local stock decrement, no server sale |
| Sale accepted | Server response is awaited before local stock update | Verify invoice ID and product/MAIN branch balances match |
| Network timeout during sale | Preserved as pending with same client reference | Retry and confirm exactly one server invoice and one stock decrement |
| Manual stock adjustment | Product/branch row locks and rollback added | Run concurrent adjustments against PostgreSQL and reconcile movement ledger |
| Duplicate return | Sale-scoped request fingerprint added | Retry same operation ID and confirm stock changes once |
| Reused return key on another sale | Expected HTTP 409 | Call endpoint against two invoices with same key and same payload |
| Legacy database migration | Compatibility migration marker is repeatable on disposable SQLite | Backup and upgrade a copy of each supported customer DB version |
| Visible placeholder routes | Explicitly labeled as not implemented | Implement or remove each placeholder before representing the feature as available |
| Docker and reverse proxy | Static configuration checks only | Build image, start compose, check `/health`, login, API calls, and image upload |
| Roles / UI buttons | Not end-to-end tested | Exercise every visible route/button for admin, pharmacist, and cashier |
