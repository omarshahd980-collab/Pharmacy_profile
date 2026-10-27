$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Backend = Join-Path $Root 'backend'
$Python = Join-Path $Backend '.venv\Scripts\python.exe'
function Test-Url([string]$Url) { try { $r=Invoke-WebRequest -UseBasicParsing -Uri $Url -TimeoutSec 2; return ($r.StatusCode -eq 200) } catch { return $false } }
function Wait-Url([string]$Url,[int]$Seconds) { for($i=0;$i -lt $Seconds;$i++){if(Test-Url $Url){return $true};Start-Sleep 1};return $false }
function Clean-Port([int]$Port){ & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root 'cleanup_port.ps1') -Port $Port; if($LASTEXITCODE -eq 2){throw "Port $Port is being used by another program."} }
Write-Host '========================================'
Write-Host 'PharmaSys - One Click Launcher'
Write-Host '========================================'
Write-Host ''
if(-not(Test-Path (Join-Path $Backend '.env'))){& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Backend 'setup_env.ps1');if($LASTEXITCODE -ne 0){throw 'Could not create Backend environment.'}}
if(-not(Test-Path $Python)){
 if(-not(Get-Command py.exe -ErrorAction SilentlyContinue)){throw 'Python 3 is not installed. Install Python 3.11 or newer, then run this file again.'}
 Write-Host '[SETUP] Creating Backend environment...'; & py.exe -3 -m venv (Join-Path $Backend '.venv'); if($LASTEXITCODE -ne 0){throw 'Could not create Backend environment.'}
}
# Install dependencies when the environment is new OR requirements.txt has changed.
# This repairs old .venv folders that exist but are missing packages.
$Requirements = Join-Path $Backend 'requirements.txt'
$Marker = Join-Path $Backend '.requirements.sha256'
$CurrentHash = (Get-FileHash -LiteralPath $Requirements -Algorithm SHA256).Hash
$SavedHash = if(Test-Path -LiteralPath $Marker){(Get-Content -LiteralPath $Marker -Raw).Trim()}else{''}
$NeedInstall = ($SavedHash -ne $CurrentHash)
if(-not $NeedInstall){
  & $Python -c "import fastapi, uvicorn, sqlalchemy, jose, passlib, dotenv" 2>$null
  if($LASTEXITCODE -ne 0){$NeedInstall = $true}
}
if($NeedInstall){
 Write-Host '[SETUP] Installing/verifying Backend dependencies. Internet may be required on first run...'
 & $Python -m pip install --upgrade pip
 if($LASTEXITCODE -ne 0){throw 'Could not update pip. Check your internet connection and Python installation.'}
 & $Python -m pip install -r $Requirements
 if($LASTEXITCODE -ne 0){throw 'Backend dependency installation failed. Check the error above; the server was not started.'}
 Set-Content -LiteralPath $Marker -Value $CurrentHash -Encoding ASCII
}
# Fail early with a clear message instead of launching a server that immediately crashes.
& $Python -c "import fastapi, uvicorn, sqlalchemy, jose, passlib, dotenv, cv2, numpy, pytesseract"
if($LASTEXITCODE -ne 0){throw 'One or more Python dependencies are still missing. Review backend/requirements.txt and the installation error above.'}
Clean-Port 8000
if(-not(Test-Url 'http://127.0.0.1:8000/health')){
 Write-Host '[START] Backend + Frontend on http://127.0.0.1:8000 ...'
 Start-Process -FilePath 'cmd.exe' -ArgumentList '/k',"cd /d `"$Backend`" && `"$Python`" -m uvicorn app.main:app --host 127.0.0.1 --port 8000" -WorkingDirectory $Backend | Out-Null
}
if(-not(Wait-Url 'http://127.0.0.1:8000/health' 45)){throw 'Backend did not become ready. Check the Backend window.'}
if(-not(Test-Url 'http://127.0.0.1:8000/')){throw 'PharmaSys web interface did not become ready.'}
Write-Host '[OK] Backend and Frontend are ready on the SAME address.'
Write-Host ('[BUILD] SIDEBAR-RIGHT-FIX-20261025-2 | Project root: ' + $Root)
Start-Process 'http://127.0.0.1:8000/?v=20261025-sidebar-right-fix2#/dashboard'
exit 0
