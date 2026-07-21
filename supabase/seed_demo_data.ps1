param(
  [string]$ProjectRef = 'lqfuubsexsljpsxlzokz',
  [string]$DemoPassword = $env:VETCARE_DEMO_PASSWORD
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$cli = Join-Path $repoRoot '.tools\supabase\supabase.exe'
$envFile = Join-Path $repoRoot '.env.local'
$baseUrl = "https://$ProjectRef.supabase.co"

function Response-Rows($Response) {
  if ($null -eq $Response) { return @() }
  if ($Response.PSObject.Properties.Name -contains 'Count' -and
      $Response.PSObject.Properties.Name -contains 'value') {
    return @($Response.value)
  }
  return @($Response)
}

function Invoke-TableGet([string]$Path) {
  return @(Response-Rows (Invoke-RestMethod -Method Get `
    -Uri "$baseUrl/rest/v1/$Path" -Headers $script:adminHeaders))
}

function Invoke-TablePost([string]$Table, [hashtable]$Body) {
  $json = $Body | ConvertTo-Json -Depth 8 -Compress
  return @(Response-Rows (Invoke-RestMethod -Method Post `
    -Uri "$baseUrl/rest/v1/$Table" -Headers $script:adminHeaders -Body $json))[0]
}

function New-DemoUser(
  [string]$Email,
  [string]$FirstName,
  [string]$LastName,
  [string]$Role,
  [string]$Document,
  [string]$Phone
) {
  $body = @{
    email = $Email
    password = $DemoPassword
    email_confirm = $true
    user_metadata = @{
      first_name = $FirstName
      last_name = $LastName
      role = $Role
      document = $Document
      phone = $Phone
      address = 'Lima, Peru'
    }
  } | ConvertTo-Json -Depth 5 -Compress
  return Invoke-RestMethod -Method Post -Uri "$baseUrl/auth/v1/admin/users" `
    -Headers $script:adminHeaders -Body $body
}

if (-not (Test-Path $envFile)) {
  throw 'Falta .env.local con SUPABASE_ACCESS_TOKEN.'
}
$tokenLine = Get-Content $envFile |
  Where-Object { $_ -like 'SUPABASE_ACCESS_TOKEN=*' } |
  Select-Object -First 1
if (-not $tokenLine) { throw 'SUPABASE_ACCESS_TOKEN no esta configurado.' }
$env:SUPABASE_ACCESS_TOKEN =
  $tokenLine.Substring('SUPABASE_ACCESS_TOKEN='.Length).Trim()

if ([string]::IsNullOrWhiteSpace($DemoPassword)) {
  $passwordLine = Get-Content $envFile |
    Where-Object { $_ -like 'VETCARE_DEMO_PASSWORD=*' } |
    Select-Object -First 1
  if ($passwordLine) {
    $DemoPassword =
      $passwordLine.Substring('VETCARE_DEMO_PASSWORD='.Length).Trim()
  }
}
if ([string]::IsNullOrWhiteSpace($DemoPassword)) {
  throw 'Configura VETCARE_DEMO_PASSWORD en .env.local o en el entorno.'
}
if ($DemoPassword.Length -lt 12) {
  throw 'VETCARE_DEMO_PASSWORD debe tener al menos 12 caracteres.'
}

$keys = (& $cli projects api-keys --project-ref $ProjectRef --output json |
  ConvertFrom-Json)
$serviceKey = ($keys | Where-Object name -eq 'service_role' |
  Select-Object -First 1).api_key
if (-not $serviceKey) { throw 'No se encontro la clave service_role.' }
$script:adminHeaders = @{
  apikey = $serviceKey
  Authorization = "Bearer $serviceKey"
  'Content-Type' = 'application/json'
  Prefer = 'return=representation'
}

$accounts = @(
  @{ email='ana.cliente.vetcare@example.com'; first='Ana'; last='Torres'; role='client'; document='DEMO-CLI-001'; phone='999100001' },
  @{ email='carlos.cliente.vetcare@example.com'; first='Carlos'; last='Ramos'; role='client'; document='DEMO-CLI-002'; phone='999100002' },
  @{ email='lucia.cliente.vetcare@example.com'; first='Lucia'; last='Vega'; role='client'; document='DEMO-CLI-003'; phone='999100003' },
  @{ email='valeria.vet.vetcare@example.com'; first='Valeria'; last='Salas'; role='veterinarian'; document='CMV-DEMO-001'; phone='999200001' },
  @{ email='rodrigo.vet.vetcare@example.com'; first='Rodrigo'; last='Paz'; role='veterinarian'; document='CMV-DEMO-002'; phone='999200002' }
)

# Repeatable reset: only the five accounts owned by this seed are removed.
$authUsers = (Invoke-RestMethod -Method Get `
  -Uri "$baseUrl/auth/v1/admin/users?page=1&per_page=1000" `
  -Headers $script:adminHeaders).users
foreach ($existing in @($authUsers | Where-Object {
  $_.email -in $accounts.email
})) {
  Invoke-RestMethod -Method Delete `
    -Uri "$baseUrl/auth/v1/admin/users/$($existing.id)" `
    -Headers $script:adminHeaders | Out-Null
}

$created = @{}
foreach ($account in $accounts) {
  $created[$account.email] = New-DemoUser `
    -Email $account.email -FirstName $account.first -LastName $account.last `
    -Role $account.role -Document $account.document -Phone $account.phone
}
Start-Sleep -Seconds 1

$clientEmails = @(
  'ana.cliente.vetcare@example.com',
  'carlos.cliente.vetcare@example.com',
  'lucia.cliente.vetcare@example.com'
)
$vetEmails = @(
  'valeria.vet.vetcare@example.com',
  'rodrigo.vet.vetcare@example.com'
)
$clients = @($clientEmails | ForEach-Object { $created[$_] })
$vetUsers = @($vetEmails | ForEach-Object { $created[$_] })
$vetRows = @($vetUsers | ForEach-Object {
  (Invoke-TableGet "veterinarians?user_id=eq.$($_.id)&select=id,user_id")[0]
})

$speciesRows = Invoke-TableGet 'species?select=id,name,is_exotic'
$specialtyRows = Invoke-TableGet 'specialties?select=id,name'
function Species-Id([string]$Name) {
  return ($speciesRows | Where-Object name -eq $Name | Select-Object -First 1).id
}
function Specialty-Id([string]$Name) {
  return ($specialtyRows | Where-Object name -eq $Name | Select-Object -First 1).id
}

# Give both veterinarians enough specialties to exercise booking filters.
$extraSpecialties = @(
  @{ vet=0; name='Dermatologia' },
  @{ vet=0; name='Cardiologia' },
  @{ vet=1; name='Cirugia' },
  @{ vet=1; name='Animales Exoticos' }
)
foreach ($entry in $extraSpecialties) {
  $normalized = $entry.name.Normalize([Text.NormalizationForm]::FormD) -replace '\p{M}', ''
  $specialty = $specialtyRows | Where-Object {
    ($_.name.Normalize([Text.NormalizationForm]::FormD) -replace '\p{M}', '') -eq $normalized
  } | Select-Object -First 1
  if ($specialty) {
    Invoke-TablePost 'veterinarian_specialties' @{
      veterinarian_id = $vetRows[$entry.vet].id
      specialty_id = $specialty.id
    } | Out-Null
  }
}

$petDefinitions = @(
  @{ owner=0; name='Luna'; species='Perro'; sex='F'; birth='2021-04-12'; weight=18.4; allergies='Polen' },
  @{ owner=0; name='Michi'; species='Gato'; sex='M'; birth='2022-09-02'; weight=4.8; allergies=$null },
  @{ owner=1; name='Rocky'; species='Perro'; sex='M'; birth='2020-01-18'; weight=27.1; allergies='Pollo' },
  @{ owner=1; name='Nala'; species='Gato'; sex='F'; birth='2023-06-20'; weight=3.9; allergies=$null },
  @{ owner=2; name='Coco'; species='Loro'; sex='M'; birth='2019-03-15'; weight=0.7; allergies=$null },
  @{ owner=2; name='Kiara'; species='Conejo'; sex='F'; birth='2022-11-08'; weight=2.3; allergies=$null }
)
$pets = @()
foreach ($definition in $petDefinitions) {
  $body = @{
    client_id = $clients[$definition.owner].id
    name = $definition.name
    species_id = (Species-Id $definition.species)
    sex_code = $definition.sex
    birth_date = $definition.birth
    weight_kg = $definition.weight
    allergies = $definition.allergies
    is_exotic = $definition.species -in @('Loro', 'Reptil', 'Exotico')
  }
  $pets += Invoke-TablePost 'pets' $body
}

$generalId = (Specialty-Id 'Medicina General')
$consultations = @()
$completed = @()
for ($i = 0; $i -lt $pets.Count; $i++) {
  $vet = $vetRows[$i % $vetRows.Count]
  $future = [DateTimeOffset]::Now.AddDays(1 + ($i % 5)).Date.AddHours(10 + $i)
  $past = [DateTimeOffset]::Now.AddDays(-1 - $i).Date.AddHours(9 + ($i % 6))
  $consultations += Invoke-TablePost 'consultations' @{
    pet_id = $pets[$i].id
    veterinarian_id = $vet.id
    specialty_id = $generalId
    scheduled_at = $future.ToString('o')
    reason = @('Control anual', 'Vacunacion', 'Revision dermatologica', 'Control dental', 'Chequeo general', 'Control nutricional')[$i]
    status = 'scheduled'
  }
  $done = Invoke-TablePost 'consultations' @{
    pet_id = $pets[$i].id
    veterinarian_id = $vet.id
    specialty_id = $generalId
    scheduled_at = $past.ToString('o')
    reason = 'Consulta de seguimiento'
    diagnosis = @('Dermatitis leve', 'Gastritis controlada', 'Otitis externa', 'Paciente saludable', 'Deficit vitaminico leve', 'Sobrecrecimiento dental')[$i]
    treatment = @('Shampoo medicado', 'Dieta blanda por 3 dias', 'Gotas cada 8 horas', 'Continuar cuidados habituales', 'Suplemento vitaminico', 'Ajuste de dieta y control')[$i]
    notes = 'Control recomendado en 30 dias'
    vitals = @{ weight_kg = $petDefinitions[$i].weight; temperature_c = 38.4 }
    status = 'completed'
    is_contagious = $i -eq 0
    started_at = $past.AddMinutes(-25).ToString('o')
    completed_at = $past.ToString('o')
  }
  $consultations += $done
  $completed += $done
  Invoke-TablePost 'morphological_records' @{
    pet_id = $pets[$i].id
    recorded_at = $past.ToString('o')
    weight_kg = $petDefinitions[$i].weight
    scale_condition = 'Normal'
    color_pattern = @('Dorado', 'Atigrado', 'Negro', 'Blanco', 'Verde', 'Marron')[$i]
    notes = 'Registro demo de control'
  } | Out-Null
}

for ($i = 0; $i -lt 4; $i++) {
  $ownerIndex = $petDefinitions[$i].owner
  $vetIndex = $i % $vetRows.Count
  Invoke-TablePost 'reviews' @{
    consultation_id = $completed[$i].id
    client_id = $clients[$ownerIndex].id
    veterinarian_id = $vetRows[$vetIndex].id
    rating = @(5, 4, 5, 4)[$i]
    comment = @('Excelente atencion', 'Muy buen trato', 'Explicacion clara', 'Atencion puntual')[$i]
  } | Out-Null
}

$medicationNames = @('Gotas oticas', 'Omeprazol veterinario', 'Shampoo medicado', 'Suplemento vitaminico')
for ($i = 0; $i -lt 4; $i++) {
  $schedule = Invoke-TablePost 'medication_schedules' @{
    consultation_id = $completed[$i].id
    medication_name = $medicationNames[$i]
    dosage = @('3 gotas', '5 mg', 'Aplicacion topica', '2 ml')[$i]
    frequency = 'Cada 8 horas'
    frequency_hours = 8
    start_date = [DateTime]::Today.AddDays(-2).ToString('yyyy-MM-dd')
    end_date = [DateTime]::Today.AddDays(7).ToString('yyyy-MM-dd')
    next_dose_at = [DateTimeOffset]::Now.AddHours(4).ToString('o')
    is_active = $true
  }
  Invoke-TablePost 'treatment_adherence' @{
    schedule_id = $schedule.id
    taken_at = [DateTimeOffset]::Now.AddHours(-4).ToString('o')
    scheduled_for = [DateTimeOffset]::Now.AddHours(-4).ToString('o')
    notes = 'Dosis registrada en datos demo'
    created_by = $clients[$petDefinitions[$i].owner].id
  } | Out-Null
}

$alertDefinitions = @(
  @{ index=0; disease='Dermatitis infecciosa'; lat=-12.0464; lng=-77.0428; severity='medium' },
  @{ index=2; disease='Parvovirus canino'; lat=-12.0762; lng=-77.0365; severity='high' },
  @{ index=4; disease='Psitacosis aviar'; lat=-12.1030; lng=-77.0300; severity='low' }
)
foreach ($alert in $alertDefinitions) {
  Invoke-TablePost 'epidemiological_alerts' @{
    consultation_id = $completed[$alert.index].id
    disease = $alert.disease
    latitude = $alert.lat
    longitude = $alert.lng
    radius_km = 3
    severity_level = $alert.severity
    is_active = $true
  } | Out-Null
}

for ($i = 0; $i -lt 2; $i++) {
  $vetUser = $vetUsers[$i % $vetUsers.Count]
  Invoke-TablePost 'consultation_documents' @{
    consultation_id = $completed[$i].id
    uploaded_by = $vetUser.id
    file_name = "resultado-demo-$($i + 1).pdf"
    storage_path = "$($vetUser.id)/$($completed[$i].id)/resultado-demo.pdf"
    content_type = 'application/pdf'
    size_bytes = 0
    doc_type = 'laboratory_result'
  } | Out-Null
  $owner = $clients[$petDefinitions[$i].owner]
  Invoke-TablePost 'legal_documents' @{
    pet_id = $pets[$i].id
    uploaded_by = $owner.id
    doc_type = 'vaccination'
    file_name = "carnet-demo-$($i + 1).pdf"
    storage_path = "$($owner.id)/$($pets[$i].id)/carnet-demo.pdf"
    expires_at = [DateTime]::Today.AddYears(1).ToString('yyyy-MM-dd')
    notes = 'Documento demostrativo'
  } | Out-Null
}

$summaryTables = @(
  'users', 'clients', 'veterinarians', 'pets', 'consultations', 'reviews',
  'medication_schedules', 'treatment_adherence', 'epidemiological_alerts',
  'morphological_records', 'consultation_documents', 'legal_documents'
)
Write-Output 'VetCare demo seed completed.'
foreach ($table in $summaryTables) {
  $rows = Invoke-TableGet "${table}?select=id"
  Write-Output "$table=$($rows.Count)"
}
Write-Output 'client_emails=ana.cliente.vetcare@example.com,carlos.cliente.vetcare@example.com,lucia.cliente.vetcare@example.com'
Write-Output 'vet_emails=valeria.vet.vetcare@example.com,rodrigo.vet.vetcare@example.com'
