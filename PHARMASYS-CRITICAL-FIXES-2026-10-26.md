# PharmaSys Critical Fixes — 2026-10-26

## Fixed in this build

1. **Product update validation**
   - Rejects empty/too-short product names and explicit `null` for required database fields before persistence.
   - Rejects selling price below purchase price on create and when either price is edited, without making legacy product reads fail.
2. **Branch stock consistency**
   - Sale decrements MAIN branch stock by the sold quantity rather than overwriting it with the product-level quantity.
   - Return, cancellation and stock-batch stock-in operations increment MAIN stock by the actual movement quantity rather than overwriting the branch balance.
   - If a MAIN branch-stock row is missing, its previous balance is reconstructed from the product-level MAIN quantity before applying the movement.
   - The existing manual stock adjustment remains a MAIN-branch operation and updates the MAIN balance to the resulting product quantity.
3. **Chatbot safety**
   - Broadened Arabic patterns for chest pain, shortness of breath, and face/tongue/throat swelling.
   - Added a supportive response path for Arabic self-harm statements; it encourages immediate help when danger may be imminent and asks whether the person is in immediate danger.
4. **Payment validation**
   - Sale payment method is restricted by the backend schema to `cash` or `card`, matching the current point-of-sale UI.

## Verification performed

- Python `compileall` passed for backend application and chatbot modules.
- Node syntax checks passed for the sales page and backend API service.
- Pydantic validation checks passed: empty name, null name, null selling price, and unsupported payment method are rejected; `cash` is accepted. The selling-price rule is enforced in the product endpoints before persistence.
- Regex checks passed for the three reported Arabic emergency examples and three Arabic self-harm phrases.
- Full API/runtime integration tests were not run: the current execution environment lacks `python-jose`, required to import the application security module. No claim is made that database transactions or browser flows were end-to-end tested.
