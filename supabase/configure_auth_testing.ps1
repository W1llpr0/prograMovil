param(
  [string]$ProjectRef = 'lqfuubsexsljpsxlzokz'
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$tokenFile = Join-Path $repoRoot '.env.local'

if (-not (Test-Path $tokenFile)) {
  throw 'Falta .env.local con SUPABASE_ACCESS_TOKEN.'
}

$tokenLine = Get-Content $tokenFile |
  Where-Object { $_ -like 'SUPABASE_ACCESS_TOKEN=*' } |
  Select-Object -First 1
if (-not $tokenLine) {
  throw 'SUPABASE_ACCESS_TOKEN no esta configurado.'
}
$accessToken = $tokenLine.Substring('SUPABASE_ACCESS_TOKEN='.Length).Trim()

# Development-only mode: email/password sign-up stays enabled, but Supabase
# confirms new users immediately and does not require a working SMTP server.
$payload = @{
  external_email_enabled = $true
  disable_signup = $false
  mailer_autoconfirm = $true
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

if (-not $verified.external_email_enabled -or
    $verified.disable_signup -or
    -not $verified.mailer_autoconfirm) {
  throw 'Supabase no aplico correctamente el modo de registro para pruebas.'
}

Write-Output 'auth_testing_mode=true'
Write-Output "external_email_enabled=$($verified.external_email_enabled)"
Write-Output "disable_signup=$($verified.disable_signup)"
Write-Output "mailer_autoconfirm=$($verified.mailer_autoconfirm)"
Write-Warning 'Modo de pruebas activo: las cuentas no verifican que el correo exista.'
