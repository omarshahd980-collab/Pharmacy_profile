# PharmaSys — Client Release

## Backend
- FastAPI + SQLAlchemy
- JWT authentication
- CORS restricted by `CORS_ORIGINS`
- Atomic sales + stock movements
- Generic server persistence for customers, suppliers, purchases, expenses, returns, shifts, delivery, notifications and activity
- Automatic bootstrap accounts on an empty database

## Default development accounts
- بيانات الـBootstrap تُحدد من `BOOTSTRAP_PASSWORD` (لا تستخدم كلمة تجريبية في الإنتاج).
- حساب الصيدلي يُنشأ تلقائيًا في بيئة التطوير.
- حساب الكاشير يُنشأ تلقائيًا في بيئة التطوير.

Change `BOOTSTRAP_PASSWORD` and `SECRET_KEY` before production.

## Frontend
The UI keeps LocalStorage as an instant cache/offline queue, but production authentication is server-first JWT. Offline authentication is disabled by default and can only be enabled explicitly for testing with `window.PHARMASYS_OFFLINE_AUTH = true`. On the next successful connection pending data is reconciled with the backend, including idempotent sales.

Set the API URL before loading the app:
```html
<script>window.PHARMASYS_API_URL = 'https://your-api.example.com';</script>
```
Or save `pharmasys_api_url` in LocalStorage.

## Demo mode
Demo account buttons are hidden by default. Enable them only for development with:
```html
<script>window.PHARMASYS_DEMO_MODE = true;</script>
```

## Production hardening
See `../QA-REPORT.md` for the automated QA results and remaining environment-dependent checks.


## UI / Client Handoff
- الواجهة RTL وتحافظ على هوية PharmaSys الحالية.
- مساعد الصيدلية يستخدم صورة الطبيب بالبالطو الأبيض في الواجهة.
- مردود المبيعات مستقل عن إلغاء الفاتورة، ويعيد الكمية للمخزون ويسجل أثر العملية.
- المخزون ظاهر كصفحة مستقلة ومربوط بالصلاحيات.
- ماسح الباركود يعمل بالكاميرا في المتصفحات التي تدعم BarcodeDetector، مع بقاء الإدخال اليدوي كبديل.
- جرى تنظيف ملفات `__pycache__` وملفات `.pyc` من نسخة التسليم.
