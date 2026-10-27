# PharmaSys repair log — 2026-10-25

## Changes in this pass
- Updated `RUN_PHARMASYS.ps1` to install/reinstall Python requirements when the requirements file changes, when its install marker is absent, or when core/OCR imports are missing. This fixes the case where an old `.venv` exists but is incomplete.
- Added early dependency checks with clearer errors before attempting to launch Uvicorn.
- Updated `START-HERE.txt` to explain that first launch requires internet access for Python packages and that Windows Tesseract OCR plus `ara`/`eng` language data are external requirements for prescription scanning.
- Improved prescription scanner error messages for missing Tesseract executable or language data.

## Checks run in this environment
- Python syntax parsing: 9 Python files passed.
- JavaScript syntax checks (`node --check`): passed for frontend JavaScript files.
- SQLite `PRAGMA integrity_check`: `ok`.
- Local environment has OpenCV, NumPy, pytesseract, Tesseract, and `ara`/`eng` language data.

## Not yet verified
- Full backend startup and authentication cannot be certified in this environment because `python-jose` and `passlib` are unavailable and package installation requires network access.
- Windows PowerShell launcher was updated but cannot be executed in this Linux validation environment.
- Browser visual checks and end-to-end sales, inventory persistence, roles, and chatbot tests require running the project on Windows.
- The bundled `pharmacy.db` has empty `users`, `products`, and `sales` tables. Existing real data should be backed up before testing or replacing any database.
