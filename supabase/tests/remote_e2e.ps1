param(
  [string]$ProjectRef = 'lqfuubsexsljpsxlzokz'
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$cli = Join-Path $repoRoot '.tools\supabase\supabase.exe'
$envFile = Join-Path $repoRoot '.env.local'
$baseUrl = "https://$ProjectRef.supabase.co"
$results = [ordered]@{}
$createdUserIds = [System.Collections.Generic.List[string]]::new()
$storageObjects = [System.Collections.Generic.List[object]]::new()

function Assert-Test([string]$Name, [bool]$Condition) {
  $results[$Name] = $Condition
  if (-not $Condition) { throw "E2E assertion failed: $Name" }
}

function New-StrongPassword {
  $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
  try {
    $bytes = New-Object byte[] 24
    $rng.GetBytes($bytes)
    return (([Convert]::ToBase64String($bytes) -replace '[+/=]', '') + 'aA7!')
  } finally {
    $rng.Dispose()
  }
}

function New-AppHeaders([string]$AccessToken, [bool]$ReturnRows = $false) {
  $headers = @{
    apikey = $script:publicKey
    Authorization = "Bearer $AccessToken"
    'Content-Type' = 'application/json'
  }
  if ($ReturnRows) { $headers.Prefer = 'return=representation' }
  return $headers
}

function New-TestUser([string]$Role, [string]$Label) {
  $email = "vetcare-e2e-$Label-$([Guid]::NewGuid().ToString('N'))@example.com"
  $password = New-StrongPassword
  $metadata = @{
    first_name = 'Prueba'
    last_name = $Label
    role = $Role
    document = if ($Role -eq 'veterinarian') { "CMV-$([Random]::new().Next(100000,999999))" } else { "$([Random]::new().Next(10000000,99999999))" }
    phone = '+51999999999'
    address = 'Lima, Perú'
  }
  $body = @{ email=$email; password=$password; email_confirm=$true; user_metadata=$metadata } |
    ConvertTo-Json -Depth 5 -Compress
  $user = Invoke-RestMethod -Method Post -Uri "$baseUrl/auth/v1/admin/users" -Headers $script:adminHeaders -Body $body
  $createdUserIds.Add($user.id) | Out-Null
  return [pscustomobject]@{ id=$user.id; email=$email; password=$password; role=$Role }
}

function Login-TestUser($User) {
  $headers = @{ apikey=$script:publicKey; 'Content-Type'='application/json' }
  $body = @{ email=$User.email; password=$User.password } | ConvertTo-Json -Compress
  return Invoke-RestMethod -Method Post -Uri "$baseUrl/auth/v1/token?grant_type=password" -Headers $headers -Body $body
}

function Expect-Denied([scriptblock]$Action) {
  try {
    & $Action | Out-Null
    return $false
  } catch {
    return $true
  }
}

function Response-Count($Response) {
  if ($null -eq $Response) { return 0 }
  if ($Response.PSObject.Properties.Name -contains 'Count' -and
      $Response.PSObject.Properties.Name -contains 'value') {
    return [int]$Response.Count
  }
  return @($Response).Count
}

function Response-Rows($Response) {
  if ($null -eq $Response) { return @() }
  if ($Response.PSObject.Properties.Name -contains 'Count' -and
      $Response.PSObject.Properties.Name -contains 'value') {
    return @($Response.value)
  }
  return @($Response)
}

$tokenLine = Get-Content $envFile | Where-Object { $_ -like 'SUPABASE_ACCESS_TOKEN=*' } | Select-Object -First 1
$env:SUPABASE_ACCESS_TOKEN = $tokenLine.Substring('SUPABASE_ACCESS_TOKEN='.Length).Trim()
$keys = (& $cli projects api-keys --project-ref $ProjectRef --output json | ConvertFrom-Json)
$script:publicKey = ($keys | Where-Object type -eq 'publishable' | Select-Object -First 1).api_key
$serviceKey = ($keys | Where-Object name -eq 'service_role' | Select-Object -First 1).api_key
$script:adminHeaders = @{ apikey=$serviceKey; Authorization="Bearer $serviceKey"; 'Content-Type'='application/json'; Prefer='return=representation' }

$consultationPath = $null
$petImagePath = $null
try {
  # Hosted Auth rejects reserved domains such as example.com before invoking
  # the database trigger. A random non-existent mailbox exercises real signup.
  $signupEmail = "vetcare.e2e.signup.$([Guid]::NewGuid().ToString('N'))@gmail.com"
  $signupPassword = New-StrongPassword
  $signupBody = @{
    email = $signupEmail
    password = $signupPassword
    data = @{
      first_name = 'Registro'
      last_name = 'Publico'
      role = 'client'
      document = "$([Random]::new().Next(10000000,99999999))"
    }
  } | ConvertTo-Json -Depth 5 -Compress
  $signupHeaders = @{ apikey=$publicKey; 'Content-Type'='application/json' }
  try {
    $signupResponse = Invoke-RestMethod -Method Post -Uri "$baseUrl/auth/v1/signup" -Headers $signupHeaders -Body $signupBody
  } catch {
    $responseBody = ''
    $responseStatus = 'unknown'
    if ($_.Exception.Response) {
      try { $responseStatus = [int]$_.Exception.Response.StatusCode } catch {}
      $reader = [IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
      try { $responseBody = $reader.ReadToEnd() } finally { $reader.Dispose() }
    }
    if ($responseStatus -eq 429) {
      $results['public_signup_rate_limit_enforced'] = $true
      $signupResponse = $null
    } elseif ($responseStatus -eq 500 -and $responseBody -like '*Error sending confirmation email*') {
      # Keep testing the application workflows even when the external SMTP
      # provider/domain is not yet able to deliver confirmation messages.
      $results['smtp_confirmation_delivery_working'] = $false
      $signupResponse = $null
    } else {
      throw "Public signup failed ($responseStatus): $responseBody"
    }
  }
  if ($null -ne $signupResponse) {
    $signupUserId = $signupResponse.user.id
    $createdUserIds.Add($signupUserId) | Out-Null
  }

  $client = New-TestUser 'client' 'Cliente'
  $vet = New-TestUser 'veterinarian' 'Veterinario'
  $outsider = New-TestUser 'client' 'Externo'
  Start-Sleep -Seconds 2

  if ($null -ne $signupResponse) {
    $signupProfile = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/users?id=eq.$signupUserId&select=id,role" -Headers $adminHeaders))
    Assert-Test 'public_signup_creates_client_profile' ($signupProfile.Count -eq 1 -and $signupProfile[0].role -eq 'client')
  }

  $clientSession = Login-TestUser $client
  $vetSession = Login-TestUser $vet
  $outsiderSession = Login-TestUser $outsider
  $clientHeaders = New-AppHeaders $clientSession.access_token $true
  $vetHeaders = New-AppHeaders $vetSession.access_token $true
  $outsiderHeaders = New-AppHeaders $outsiderSession.access_token $true

  $profiles = @()
  foreach ($testUser in @($client, $vet, $outsider)) {
    $profiles += @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/users?id=eq.$($testUser.id)&select=id,role" -Headers $adminHeaders))
  }
  Assert-Test 'auth_profiles_created' ($profiles.Count -eq 3)

  $updatedClientProfile = @(Response-Rows (Invoke-RestMethod -Method Patch -Uri "$baseUrl/rest/v1/users?id=eq.$($client.id)&select=phone,latitude,longitude" -Headers $clientHeaders -Body (@{ phone='+51911111111'; latitude=-12.0464; longitude=-77.0428 } | ConvertTo-Json)))
  Assert-Test 'client_profile_update_saved' ($updatedClientProfile.Count -eq 1 -and $updatedClientProfile[0].phone -eq '+51911111111')
  $species = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/species?select=id,name&order=id&limit=1" -Headers $clientHeaders))[0]
  $breeds = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/breeds?species_id=eq.$($species.id)&select=id,name&order=id&limit=1" -Headers $clientHeaders))
  $breedId = if ($breeds.Count -gt 0) { $breeds[0].id } else { $null }

  $petBody = @{ client_id=$client.id; name='Firulais E2E'; species_id=$species.id; breed_id=$breedId; sex_code='M'; weight_kg=12.5; allergies='Ninguna' } | ConvertTo-Json -Compress
  $pet = @(Response-Rows (Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/pets?select=*" -Headers $clientHeaders -Body $petBody))[0]
  $outsiderPetBody = @{ client_id=$outsider.id; name='Privado E2E'; species_id=$species.id; breed_id=$breedId; sex_code='F'; weight_kg=5.0 } | ConvertTo-Json -Compress
  $outsiderPet = @(Response-Rows (Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/pets?select=*" -Headers $outsiderHeaders -Body $outsiderPetBody))[0]
  Assert-Test 'client_can_create_pet' ($pet.client_id -eq $client.id)
  $updatedPet = @(Response-Rows (Invoke-RestMethod -Method Patch -Uri "$baseUrl/rest/v1/pets?id=eq.$($pet.id)&select=id,weight_kg" -Headers $clientHeaders -Body (@{weight_kg=13.0}|ConvertTo-Json)))
  Assert-Test 'owner_can_update_pet' ($updatedPet.Count -eq 1 -and [double]$updatedPet[0].weight_kg -eq 13.0)

  $morphologyBody = @{ pet_id=$pet.id; length_cm=45.2; weight_kg=12.5; scale_condition='normal'; color_pattern='marron'; notes='Registro E2E' } | ConvertTo-Json -Compress
  $morphology = @(Response-Rows (Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/morphological_records?select=id,pet_id" -Headers $clientHeaders -Body $morphologyBody))
  $outsiderMorphology = Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/morphological_records?pet_id=eq.$($pet.id)&select=id" -Headers $outsiderHeaders
  Assert-Test 'owner_can_create_morphological_record' ($morphology.Count -eq 1)
  Assert-Test 'outsider_cannot_read_morphological_record' ((Response-Count $outsiderMorphology) -eq 0)

  $vetRow = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/veterinarians?user_id=eq.$($vet.id)&select=id,user_id,license_number" -Headers $vetHeaders))[0]
  $specialty = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/veterinarian_specialties?veterinarian_id=eq.$($vetRow.id)&select=specialty_id&limit=1" -Headers $vetHeaders))[0]
  Assert-Test 'veterinarian_trigger_created' ($vetRow.user_id -eq $vet.id)
  $updatedVet = @(Response-Rows (Invoke-RestMethod -Method Patch -Uri "$baseUrl/rest/v1/veterinarians?id=eq.$($vetRow.id)&select=license_number,years_experience" -Headers $vetHeaders -Body (@{license_number="CMV-E2E-$([Random]::new().Next(1000,9999))";years_experience=9}|ConvertTo-Json)))
  Assert-Test 'veterinarian_profile_update_saved' ($updatedVet.Count -eq 1 -and [int]$updatedVet[0].years_experience -eq 9)
  $alternateSpecialty = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/specialties?id=neq.$($specialty.specialty_id)&select=id&limit=1" -Headers $vetHeaders))[0]
  $addedSpecialty = @(Response-Rows (Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/veterinarian_specialties?select=specialty_id" -Headers $vetHeaders -Body (@{veterinarian_id=$vetRow.id;specialty_id=$alternateSpecialty.id}|ConvertTo-Json)))
  Assert-Test 'veterinarian_can_add_specialty' ($addedSpecialty.Count -eq 1)

  $vetBeforeBooking = Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/pets?id=eq.$($pet.id)&select=id" -Headers $vetHeaders
  $outsiderCannotRead = Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/pets?id=eq.$($pet.id)&select=id" -Headers $outsiderHeaders
  Assert-Test 'vet_cannot_read_unassigned_pet' ((Response-Count $vetBeforeBooking) -eq 0)
  Assert-Test 'client_cannot_read_other_pet' ((Response-Count $outsiderCannotRead) -eq 0)

  $slotDate = (Get-Date).Date.AddDays(1)
  while ($slotDate.DayOfWeek -eq [DayOfWeek]::Sunday) { $slotDate = $slotDate.AddDays(1) }
  $slotsBody = @{ p_veterinarian_id=$vetRow.id; p_date=$slotDate.ToString('yyyy-MM-dd') } | ConvertTo-Json -Compress
  $slots = @(Response-Rows (Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/available_slots" -Headers $clientHeaders -Body $slotsBody))
  Assert-Test 'available_slots_returned' ($slots.Count -gt 0)
  $slotAt = $slots[0].slot_at

  $bookingBody = @{ p_pet_id=$pet.id; p_veterinarian_id=$vetRow.id; p_specialty_id=$specialty.specialty_id; p_scheduled_at=$slotAt; p_reason='Control integral E2E' } | ConvertTo-Json -Compress
  $booking = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/book_consultation" -Headers $clientHeaders -Body $bookingBody
  $consultationId = $booking.data.id
  Assert-Test 'consultation_booked' ($booking.success -and $booking.code -eq 'CONSULTATION_BOOKED')

  $duplicate = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/book_consultation" -Headers $clientHeaders -Body $bookingBody
  Assert-Test 'duplicate_slot_rejected' (-not $duplicate.success -and $duplicate.code -eq 'SLOT_TAKEN')
  $clientStart = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/start_consultation" -Headers $clientHeaders -Body (@{p_consultation_id=$consultationId}|ConvertTo-Json)
  Assert-Test 'client_cannot_start_consultation' (-not $clientStart.success -and $clientStart.code -eq 'CONSULTATION_FORBIDDEN')
  $outsiderConsultation = Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/consultations?id=eq.$consultationId&select=id" -Headers $outsiderHeaders
  Assert-Test 'outsider_cannot_read_consultation' ((Response-Count $outsiderConsultation) -eq 0)
  $vetAfterBooking = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/pets?id=eq.$($pet.id)&select=id" -Headers $vetHeaders))
  Assert-Test 'assigned_vet_can_read_pet' ($vetAfterBooking.Count -eq 1)
  $vetMorphology = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/morphological_records?pet_id=eq.$($pet.id)&select=id" -Headers $vetHeaders))
  Assert-Test 'assigned_vet_can_read_morphological_record' ($vetMorphology.Count -eq 1)

  $started = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/start_consultation" -Headers $vetHeaders -Body (@{p_consultation_id=$consultationId}|ConvertTo-Json)
  Assert-Test 'vet_can_start_consultation' ($started.success -and $started.code -eq 'CONSULTATION_STARTED')
  $draft = @(Response-Rows (Invoke-RestMethod -Method Patch -Uri "$baseUrl/rest/v1/consultations?id=eq.$consultationId&select=id,status,diagnosis" -Headers $vetHeaders -Body (@{status='in_progress';diagnosis='Borrador E2E';treatment='Tratamiento borrador E2E';vitals=@{weight_kg=13.0}}|ConvertTo-Json -Depth 4)))
  Assert-Test 'veterinarian_can_save_consultation_draft' ($draft.Count -eq 1 -and $draft[0].status -eq 'in_progress' -and $draft[0].diagnosis -eq 'Borrador E2E')
  # Keep the signed test vector ASCII-only so Windows PowerShell 5.1 and
  # PowerShell 7 calculate exactly the same UTF-8 bytes on every machine.
  $diagnosis = 'Traqueobronquitis infecciosa E2E'
  $treatment = 'Reposo, hidratacion y medicacion E2E'
  $medications = @(@{ name='Amoxicilina E2E'; dosage='250 mg'; frequency='Cada 8 horas'; frequency_hours=8; start_date=(Get-Date).ToString('yyyy-MM-dd'); end_date=(Get-Date).AddDays(7).ToString('yyyy-MM-dd'); next_dose_at=(Get-Date).AddHours(8).ToString('o') })
  $completeBody = @{ p_consultation_id=$consultationId; p_diagnosis=$diagnosis; p_treatment=$treatment; p_notes='Prueba completa'; p_is_contagious=$true; p_vitals=@{weight_kg=12.5;temperature_c=38.4;heart_rate_bpm=96}; p_medications=$medications } | ConvertTo-Json -Depth 8 -Compress
  $clientComplete = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/complete_consultation" -Headers $clientHeaders -Body $completeBody
  Assert-Test 'client_cannot_complete_consultation' (-not $clientComplete.success -and $clientComplete.code -eq 'CONSULTATION_FORBIDDEN')
  $completed = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/complete_consultation" -Headers $vetHeaders -Body $completeBody
  Assert-Test 'consultation_completed' ($completed.success -and $completed.code -eq 'CONSULTATION_COMPLETED')

  $canonical = "$consultationId|$diagnosis|$treatment"
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $expectedHash = ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($canonical)))).Replace('-','').ToLowerInvariant() } finally { $sha.Dispose() }
  Assert-Test 'integrity_hash_valid' ($completed.data.integrity_hash -eq $expectedHash)

  $meds = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/medication_schedules?consultation_id=eq.$consultationId&select=*" -Headers $clientHeaders))
  $alerts = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/epidemiological_alerts?consultation_id=eq.$consultationId&select=*" -Headers $clientHeaders))
  Assert-Test 'medication_created' ($meds.Count -eq 1)
  Assert-Test 'epidemiological_alert_created' ($alerts.Count -eq 1 -and $alerts[0].severity_level -eq 'high')

  $dueAt = (Get-Date).AddMinutes(-5).ToUniversalTime().ToString('o')
  Invoke-RestMethod -Method Patch -Uri "$baseUrl/rest/v1/medication_schedules?id=eq.$($meds[0].id)" -Headers $adminHeaders -Body (@{next_dose_at=$dueAt}|ConvertTo-Json) | Out-Null
  $doseBody = @{ p_schedule_id=$meds[0].id; p_notes='Tomada E2E' } | ConvertTo-Json -Compress
  $outsiderDose = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/record_medication_dose" -Headers $outsiderHeaders -Body $doseBody
  Assert-Test 'outsider_cannot_record_medication' (-not $outsiderDose.success -and $outsiderDose.code -eq 'SCHEDULE_FORBIDDEN')
  $dose = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/record_medication_dose" -Headers $clientHeaders -Body $doseBody
  Assert-Test 'medication_dose_recorded_atomically' ($dose.success -and $dose.code -eq 'DOSE_RECORDED')
  $duplicateDose = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/record_medication_dose" -Headers $clientHeaders -Body $doseBody
  Assert-Test 'immediate_duplicate_dose_rejected' (-not $duplicateDose.success -and $duplicateDose.code -eq 'DOSE_TOO_EARLY')
  $adherence = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/treatment_adherence?schedule_id=eq.$($meds[0].id)&select=id" -Headers $clientHeaders))
  Assert-Test 'single_adherence_row_created' ($adherence.Count -eq 1)
  $directAdherenceDenied = Expect-Denied { Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/treatment_adherence" -Headers $clientHeaders -Body (@{schedule_id=$meds[0].id;scheduled_for=(Get-Date).ToString('o');created_by=$client.id}|ConvertTo-Json) }
  Assert-Test 'direct_adherence_write_denied' $directAdherenceDenied

  $outsiderReview = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/submit_review" -Headers $outsiderHeaders -Body (@{p_consultation_id=$consultationId;p_rating=5;p_comment='No permitida'}|ConvertTo-Json)
  Assert-Test 'outsider_review_rejected' (-not $outsiderReview.success -and $outsiderReview.code -eq 'REVIEW_FORBIDDEN')
  $review = Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/rpc/submit_review" -Headers $clientHeaders -Body (@{p_consultation_id=$consultationId;p_rating=5;p_comment='Excelente atención E2E'}|ConvertTo-Json)
  Assert-Test 'owner_review_saved' ($review.success -and $review.code -eq 'REVIEW_SAVED')
  $reviewContext = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/reviews?consultation_id=eq.$consultationId&select=*,consultations!inner(scheduled_at,diagnosis,pets!inner(name),specialties(name))" -Headers $clientHeaders))
  Assert-Test 'review_includes_clinical_context' ($reviewContext.Count -eq 1 -and $reviewContext[0].consultations.pets.name -eq 'Firulais E2E' -and $reviewContext[0].consultations.diagnosis -eq $diagnosis)
  $directReviewDenied = Expect-Denied { Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/reviews" -Headers $clientHeaders -Body (@{consultation_id=$consultationId;client_id=$client.id;veterinarian_id=$vetRow.id;rating=1}|ConvertTo-Json) }
  Assert-Test 'direct_review_write_denied' $directReviewDenied

  $directBookingDenied = Expect-Denied { Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/consultations" -Headers $clientHeaders -Body (@{pet_id=$pet.id;veterinarian_id=$vetRow.id;scheduled_at=(Get-Date).AddDays(10).ToString('o')}|ConvertTo-Json) }
  Assert-Test 'direct_booking_write_denied' $directBookingDenied
  $directRoleDenied = Expect-Denied { Invoke-RestMethod -Method Patch -Uri "$baseUrl/rest/v1/users?id=eq.$($client.id)" -Headers $clientHeaders -Body (@{role='veterinarian'}|ConvertTo-Json) }
  Assert-Test 'direct_role_escalation_denied' $directRoleDenied
  Invoke-RestMethod -Method Put -Uri "$baseUrl/auth/v1/user" -Headers $clientHeaders -Body (@{data=@{role='veterinarian'}}|ConvertTo-Json -Depth 4) | Out-Null
  Start-Sleep -Seconds 1
  $roleAfterMetadata = @(Response-Rows (Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/users?id=eq.$($client.id)&select=role" -Headers $clientHeaders))[0].role
  $fakeVetRows = Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/veterinarians?user_id=eq.$($client.id)&select=id" -Headers $adminHeaders
  Assert-Test 'metadata_role_escalation_blocked' ($roleAfterMetadata -eq 'client' -and (Response-Count $fakeVetRows) -eq 0)

  $pngBytes = [Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=')
  $petImagePath = "$($client.id)/e2e-pet.png"
  $petStorageHeaders = @{ apikey=$publicKey; Authorization="Bearer $($clientSession.access_token)"; 'x-upsert'='true' }
  Invoke-WebRequest -Method Post -Uri "$baseUrl/storage/v1/object/pet-images/$petImagePath" -Headers $petStorageHeaders -ContentType 'image/png' -Body $pngBytes | Out-Null
  $storageObjects.Add([pscustomobject]@{bucket='pet-images';path=$petImagePath}) | Out-Null
  $publicImage = Invoke-WebRequest -Method Get -Uri "$baseUrl/storage/v1/object/public/pet-images/$petImagePath"
  Assert-Test 'public_pet_image_roundtrip' ($publicImage.StatusCode -eq 200)

  $profilePath = "profile-pictures/$($client.id)/profile.jpg"
  Invoke-WebRequest -Method Post -Uri "$baseUrl/storage/v1/object/profiles/$profilePath" -Headers $petStorageHeaders -ContentType 'image/png' -Body $pngBytes | Out-Null
  $storageObjects.Add([pscustomobject]@{bucket='profiles';path=$profilePath}) | Out-Null
  $publicProfile = Invoke-WebRequest -Method Get -Uri "$baseUrl/storage/v1/object/public/profiles/$profilePath"
  Assert-Test 'public_profile_upsert_roundtrip' ($publicProfile.StatusCode -eq 200)

  $legalPath = "$($client.id)/$($pet.id)/e2e-legal.png"
  $clientStorageHeaders = @{ apikey=$publicKey; Authorization="Bearer $($clientSession.access_token)" }
  Invoke-WebRequest -Method Post -Uri "$baseUrl/storage/v1/object/legal-docs/$legalPath" -Headers $clientStorageHeaders -ContentType 'image/png' -Body $pngBytes | Out-Null
  $storageObjects.Add([pscustomobject]@{bucket='legal-docs';path=$legalPath}) | Out-Null
  $legalBody = @{ pet_id=$pet.id; uploaded_by=$client.id; doc_type='vaccination'; file_name='e2e-legal.png'; storage_path=$legalPath; file_url=$legalPath; notes='Documento E2E' } | ConvertTo-Json -Compress
  $legalRow = @(Response-Rows (Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/legal_documents?select=id" -Headers $clientHeaders -Body $legalBody))
  Assert-Test 'owner_can_create_legal_document' ($legalRow.Count -eq 1)
  $ownerLegalRead = Invoke-WebRequest -Method Get -Uri "$baseUrl/storage/v1/object/authenticated/legal-docs/$legalPath" -Headers $clientStorageHeaders
  Assert-Test 'owner_can_read_private_legal_document' ($ownerLegalRead.StatusCode -eq 200)
  $outsiderStorageHeaders = @{ apikey=$publicKey; Authorization="Bearer $($outsiderSession.access_token)" }
  $outsiderLegalDenied = Expect-Denied { Invoke-WebRequest -Method Get -Uri "$baseUrl/storage/v1/object/authenticated/legal-docs/$legalPath" -Headers $outsiderStorageHeaders }
  Assert-Test 'outsider_cannot_read_private_legal_document' $outsiderLegalDenied

  $consultationPath = "$($vet.id)/$consultationId/e2e-result.png"
  $vetStorageHeaders = @{ apikey=$publicKey; Authorization="Bearer $($vetSession.access_token)" }
  Invoke-WebRequest -Method Post -Uri "$baseUrl/storage/v1/object/consultation-docs/$consultationPath" -Headers $vetStorageHeaders -ContentType 'image/png' -Body $pngBytes | Out-Null
  $storageObjects.Add([pscustomobject]@{bucket='consultation-docs';path=$consultationPath}) | Out-Null
  $docBody = @{ consultation_id=$consultationId; uploaded_by=$vet.id; file_name='e2e-result.png'; storage_path=$consultationPath; file_url=$consultationPath; content_type='image/png'; size_bytes=$pngBytes.Length } | ConvertTo-Json -Compress
  $doc = @(Response-Rows (Invoke-RestMethod -Method Post -Uri "$baseUrl/rest/v1/consultation_documents?select=id" -Headers $vetHeaders -Body $docBody))
  Assert-Test 'consultation_document_row_created' ($doc.Count -eq 1)
  $privateRead = Invoke-WebRequest -Method Get -Uri "$baseUrl/storage/v1/object/authenticated/consultation-docs/$consultationPath" -Headers $clientStorageHeaders
  Assert-Test 'owner_can_read_private_document' ($privateRead.StatusCode -eq 200)
  $outsiderDocumentDenied = Expect-Denied { Invoke-WebRequest -Method Get -Uri "$baseUrl/storage/v1/object/authenticated/consultation-docs/$consultationPath" -Headers $outsiderStorageHeaders }
  Assert-Test 'outsider_cannot_read_private_document' $outsiderDocumentDenied
  $deleteDocumentBody = @{prefixes=@($consultationPath)} | ConvertTo-Json -Depth 3 -Compress
  Invoke-RestMethod -Method Delete -Uri "$baseUrl/storage/v1/object/consultation-docs" -Headers $vetHeaders -Body $deleteDocumentBody | Out-Null
  Invoke-RestMethod -Method Delete -Uri "$baseUrl/rest/v1/consultation_documents?id=eq.$($doc[0].id)" -Headers $vetHeaders | Out-Null
  $deletedDocuments = Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/consultation_documents?id=eq.$($doc[0].id)&select=id" -Headers $vetHeaders
  Assert-Test 'veterinarian_can_delete_clinical_document' ((Response-Count $deletedDocuments) -eq 0)

  Invoke-RestMethod -Method Delete -Uri "$baseUrl/rest/v1/pets?id=eq.$($pet.id)" -Headers $clientHeaders | Out-Null
  $deletedPet = Invoke-RestMethod -Method Get -Uri "$baseUrl/rest/v1/pets?id=eq.$($pet.id)&select=id" -Headers $adminHeaders
  Assert-Test 'owner_can_delete_pet' ((Response-Count $deletedPet) -eq 0)

  [pscustomobject]$results | ConvertTo-Json
} finally {
  $cleanupErrors = [System.Collections.Generic.List[string]]::new()
  foreach ($bucket in @($storageObjects | Select-Object -ExpandProperty bucket -Unique)) {
    $paths = @($storageObjects | Where-Object bucket -eq $bucket | Select-Object -ExpandProperty path)
    try {
      $deleteBody = @{ prefixes=$paths } | ConvertTo-Json -Depth 4 -Compress
      Invoke-RestMethod -Method Delete -Uri "$baseUrl/storage/v1/object/$bucket" -Headers $adminHeaders -Body $deleteBody | Out-Null
    } catch {
      $cleanupErrors.Add("storage:$bucket") | Out-Null
    }
  }
  foreach ($userId in $createdUserIds) {
    try {
      Invoke-RestMethod -Method Delete -Uri "$baseUrl/auth/v1/admin/users/$userId" -Headers $adminHeaders | Out-Null
    } catch {
      $cleanupErrors.Add("auth-user:$userId") | Out-Null
    }
  }
  if ($cleanupErrors.Count -gt 0) {
    throw "E2E cleanup failed for: $($cleanupErrors -join ', ')"
  }
}
