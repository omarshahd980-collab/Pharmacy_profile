$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Css = Join-Path $Root 'frontend\css\true-light-rtl-fix.css'
$Html = Join-Path $Root 'frontend\index.html'
if (!(Test-Path $Css) -or !(Test-Path $Html)) {
  Write-Host 'ERROR: Put this script in the PharmaSys-Client-Ready project root (the folder containing frontend).' -ForegroundColor Red
  Read-Host 'Press Enter to close'
  exit 1
}
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item $Css "$Css.backup-$Stamp"
Copy-Item $Html "$Html.backup-$Stamp"
$cssText = Get-Content $Css -Raw
$marker = '/* VERIFIED GLOBAL TYPOGRAPHY FIX - 20261022-font-fix10 */'
if ($cssText -notmatch [regex]::Escape($marker)) {
  $patch = @'

/* VERIFIED GLOBAL TYPOGRAPHY FIX - 20261022-font-fix10 */
/* Normalize ordinary interface text to 14px while preserving heading hierarchy and icon glyphs. */
#app { font-size: 14px !important; }
#app :is(p, label, input, select, textarea, td, th, .nav-link, .nav-section-label,
  .user-name, .user-role, .logo-text, .page-description, .form-hint, .muted,
  .badge, .status-badge, .table-container, .empty-state, .help-text) {
  font-size: 14px !important;
}
#app :is(.page-title, h1) { font-size: 24px !important; }
#app :is(h2, .section-title, .card-title) { font-size: 18px !important; }
#app :is(h3, h4) { font-size: 16px !important; }
#app :is(.icon, i[class*="fa-"], [class^="fa-"], [class*=" fa-"], svg) {
  font-size: inherit !important;
}
'@
  Add-Content -Path $Css -Value $patch -Encoding UTF8
}
$htmlText = Get-Content $Html -Raw
$htmlText = [regex]::Replace($htmlText, '(css/dashboard-reference-rtl\.css\?v=)[^"''\s>]+', '${1}20261022-font-fix10')
$htmlText = [regex]::Replace($htmlText, '(css/true-light-rtl-fix\.css\?v=)[^"''\s>]+', '${1}20261022-font-fix10')
Set-Content -Path $Html -Value $htmlText -Encoding UTF8
Write-Host 'SUCCESS: Font fix applied. Backups were created beside both files.' -ForegroundColor Green
Write-Host 'Next: restart the PharmaSys server from THIS project folder, then press Ctrl+F5.' -ForegroundColor Yellow
Read-Host 'Press Enter to close'
