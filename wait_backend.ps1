$ErrorActionPreference = "SilentlyContinue"
try {
    $r = Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:8000/health" -TimeoutSec 2
    if ($r.StatusCode -eq 200) { exit 0 }
} catch {}
exit 1
