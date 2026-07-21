param(
  [string]$ProjectRef = 'lqfuubsexsljpsxlzokz',
  [string]$ConfigFile = (Join-Path $PSScriptRoot '.env.smtp.local')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$tokenFile = Join-Path $repoRoot '.env.local'

function Read-EnvFile([string]$Path) {
  $values = @{}
  foreach ($line in Get-Content $Path) {
    $trimmed = $line.Trim()
    if (-not $trimmed -or $trimmed.StartsWith('#')) { continue }
    $separator = $trimmed.IndexOf('=')
    if ($separator -lt 1) { continue }
    $key = $trimmed.Substring(0, $separator).Trim()
    $value = $trimmed.Substring($separator + 1).Trim()
    $values[$key] = $value
  }
  return $values
}

if (-not (Test-Path $ConfigFile)) {
  throw "Falta $ConfigFile. Copia .env.smtp.example como .env.smtp.local."
}
if (-not (Test-Path $tokenFile)) {
  throw 'Falta .env.local con SUPABASE_ACCESS_TOKEN.'
}

$smtp = Read-EnvFile $ConfigFile
$required = @(
  'SMTP_HOST', 'SMTP_PORT', 'SMTP_USER', 'SMTP_PASS',
  'SMTP_ADMIN_EMAIL', 'SMTP_SENDER_NAME'
)
foreach ($key in $required) {
  if (-not $smtp[$key] -or $smtp[$key] -like 'REEMPLAZAR*') {
    throw "Falta configurar $key."
  }
}
$port = 0
if (-not [int]::TryParse($smtp['SMTP_PORT'], [ref]$port)) {
  throw 'SMTP_PORT debe ser numerico.'
}
$rateLimit = 30
if ($smtp['SMTP_RATE_LIMIT_EMAIL_SENT'] -and
    -not [int]::TryParse($smtp['SMTP_RATE_LIMIT_EMAIL_SENT'], [ref]$rateLimit)) {
  throw 'SMTP_RATE_LIMIT_EMAIL_SENT debe ser numerico.'
}

$tokenLine = Get-Content $tokenFile |
  Where-Object { $_ -like 'SUPABASE_ACCESS_TOKEN=*' } |
  Select-Object -First 1
if (-not $tokenLine) { throw 'SUPABASE_ACCESS_TOKEN no esta configurado.' }
$accessToken = $tokenLine.Substring('SUPABASE_ACCESS_TOKEN='.Length).Trim()

$payload = @{
  external_email_enabled = $true
  mailer_autoconfirm = $false
  smtp_admin_email = $smtp['SMTP_ADMIN_EMAIL']
  smtp_host = $smtp['SMTP_HOST']
  # The hosted Management API currently models smtp_port as a string.
  smtp_port = $smtp['SMTP_PORT']
  smtp_user = $smtp['SMTP_USER']
  smtp_pass = $smtp['SMTP_PASS']
  smtp_sender_name = $smtp['SMTP_SENDER_NAME']
  rate_limit_email_sent = $rateLimit
} | ConvertTo-Json -Compress

Invoke-RestMethod -Method Patch `
  -Uri "https://api.supabase.com/v1/projects/$ProjectRef/config/auth" `
  -Headers @{
    Authorization = "Bearer $accessToken"
    'Content-Type' = 'application/json'
  } `
  -Body $payload | Out-Null

$verified = Invoke-RestMethod -Method Get `
  -Uri "https://api.supabase.com/v1/projects/$ProjectRef/config/auth" `
  -Headers @{ Authorization = "Bearer $accessToken" }

if (-not $verified.smtp_host) {
  throw 'Supabase no devolvio una configuracion SMTP activa.'
}
Write-Output 'smtp_configured=true'
Write-Output "smtp_host=$($verified.smtp_host)"
Write-Output "smtp_sender=$($verified.smtp_admin_email)"
Write-Output "mailer_autoconfirm=$($verified.mailer_autoconfirm)"
Write-Output "rate_limit_email_sent=$($verified.rate_limit_email_sent)"
