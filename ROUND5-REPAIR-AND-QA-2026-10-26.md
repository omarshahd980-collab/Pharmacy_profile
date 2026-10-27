# PharmaSys Round 5 — Repairs and QA
Date: 2026-10-26
Base: ROUND4-FINANCIAL-STOCK-DELIVERY-FIXES

## Changes applied
1. Category creation trims names, checks existing names case-insensitively, and catches a database integrity conflict so a duplicate race returns HTTP 409 instead of an unhandled HTTP 500.
2. Cancelling an invoice that has already been fully returned now returns HTTP 409 rather than recording a second incompatible financial operation.
3. The 30-day summary now bounds sales to the report period, excludes cancelled and fully returned invoices from sales count, subtracts returns issued in the period, and avoids subtracting a cancellation refund a second time when the cancelled invoice is already excluded from revenue.

## Validation performed
- Python compileall passed for backend app, chatbot, and prescription scanner.
- `node --check` passed for all frontend JavaScript files.
- ZIP integrity check passed after packaging.

## Not yet verified
- Live authenticated API integration using the real `python-jose`, `passlib`, and `bcrypt` dependencies.
- Browser end-to-end checks for every route and visible button.
- PostgreSQL concurrent transaction tests and Docker Compose startup.
- Category names differing only by letter case are checked before insert, but the current schema's ordinary unique constraint is not a database-level case-insensitive unique index; add a managed migration after checking existing data before production if case-insensitive uniqueness must be guaranteed under concurrency.

Do not use this report as production certification. Back up existing data and test upgrades on a copy before deployment.
