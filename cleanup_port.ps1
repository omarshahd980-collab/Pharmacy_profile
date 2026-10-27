param([Parameter(Mandatory=$true)][int]$Port)
$ErrorActionPreference = "Stop"

function Test-Healthy([int]$CheckPort) {
  try {
    $uri = if ($CheckPort -eq 8000) { 'http://127.0.0.1:8000/health' } else { 'http://127.0.0.1:5500/' }
    $r = Invoke-WebRequest -UseBasicParsing -Uri $uri -TimeoutSec 1
    return ($r.StatusCode -eq 200)
  } catch { return $false }
}

$connections = @()
try { $connections = @(Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop) } catch {
  $connections = @(netstat -ano | Select-String -Pattern (":$Port\s+.*LISTENING\s+(\d+)$")) | ForEach-Object {
    if ($_.ToString() -match ":$Port\s+\S+\s+LISTENING\s+(\d+)$") { [pscustomobject]@{ OwningProcess = [int]$Matches[1] } }
  }
}
if (-not $connections -or $connections.Count -eq 0) { exit 0 }

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$seen = @{}
foreach ($connection in $connections) {
  $ownerPid = [int]$connection.OwningProcess
  if ($seen.ContainsKey($ownerPid)) { continue }
  $seen[$ownerPid] = $true
  try {
    $process = Get-Process -Id $ownerPid -ErrorAction Stop
    $processName = $process.ProcessName.ToLowerInvariant()
    if ($processName -notin @('python','python3','pythonw')) {
      Write-Host "[ERROR] Port $Port is occupied by $processName (PID $ownerPid)."
      exit 2
    }
    $cmd = ''
    try { $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId = $ownerPid").CommandLine } catch {}
    $isOurBackend = ($Port -eq 8000 -and $cmd -match 'uvicorn.*app\.main:app' -and $cmd -match [regex]::Escape((Join-Path $root 'backend')))
    $isOurFrontend = ($Port -eq 5500 -and $cmd -match 'http\.server\s+5500' -and $cmd -match [regex]::Escape($root))
    if ($isOurBackend -or $isOurFrontend) {
      Stop-Process -Id $ownerPid -Force -ErrorAction Stop
      Start-Sleep -Milliseconds 800
    } elseif ($cmd -and ($cmd -match 'uvicorn.*app\.main:app' -or $cmd -match 'http\.server\s+5500')) {
      # A stale PharmaSys Python server from an older extracted copy. It is safe to replace on these dedicated ports.
      Stop-Process -Id $ownerPid -Force -ErrorAction Stop
      Start-Sleep -Milliseconds 800
    } else {
      Write-Host "[ERROR] Port $Port is occupied by another Python program (PID $ownerPid)."
      exit 2
    }
  } catch {
    Write-Host "[ERROR] Could not release port $Port (PID $ownerPid)."
    exit 2
  }
}
exit 0
