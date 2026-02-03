$base = "http://localhost:3000"
$ts = Get-Date -Format "yyyyMMddHHmmss"
$email = "test$ts@example.com"
$password = "Password123"
$name = "Test User $ts"

function Invoke-CurlTest {
  param(
    [string]$Name,
    [string]$Method,
    [string]$Url,
    [hashtable]$Headers,
    [string]$Body
  )

  $args = @('-s', '-X', $Method, $Url, '-w', "\nHTTP_STATUS:%{http_code}")
  if ($Headers) {
    foreach ($key in $Headers.Keys) {
      $args += '-H'
      $args += "$($key): $($Headers[$key])"
    }
  }

  $tempFile = $null
  if ($Body -and $Method -in @('POST', 'PUT', 'PATCH')) {
    $tempFile = New-TemporaryFile
    [System.IO.File]::WriteAllText($tempFile.FullName, $Body)
    $args += '-H'
    $args += 'Content-Type: application/json'
    $args += '--data-binary'
    $args += "@" + $tempFile.FullName
  }

  $raw = & curl.exe @args
  if ($tempFile) { Remove-Item $tempFile.FullName -Force }

  $output = ($raw -join "`n")
  $marker = "HTTP_STATUS:"
  $idx = $output.LastIndexOf($marker)
  if ($idx -ge 0) {
    $content = $output.Substring(0, $idx).TrimEnd()
    $statusText = $output.Substring($idx + $marker.Length).Trim()
  } else {
    $content = $output
    $statusText = "0"
  }

  $status = 0
  [int]::TryParse($statusText, [ref]$status) | Out-Null

  return [pscustomobject]@{
    name = $Name
    method = $Method
    url = $Url
    payload = $Body
    status = $status
    response = $content
  }
}

$results = @()

$results += Invoke-CurlTest -Name "GET /" -Method "GET" -Url "$base/"
$results += Invoke-CurlTest -Name "GET /api-docs.json" -Method "GET" -Url "$base/api-docs.json"

$registerPayload = @{ name = $name; email = $email; password = $password } | ConvertTo-Json -Compress
$results += Invoke-CurlTest -Name "POST /api/auth/register" -Method "POST" -Url "$base/api/auth/register" -Body $registerPayload

$loginPayload = @{ email = $email; password = $password } | ConvertTo-Json -Compress
$loginResult = Invoke-CurlTest -Name "POST /api/auth/login" -Method "POST" -Url "$base/api/auth/login" -Body $loginPayload
$results += $loginResult

$loginObj = $null
try { $loginObj = $loginResult.response | ConvertFrom-Json } catch {}
$token = $loginObj.token
$userId = $loginObj.user.id

$authHeaders = @{}
if ($token) { $authHeaders = @{ Authorization = "Bearer $token" } }

$results += Invoke-CurlTest -Name "GET /api/events (no token)" -Method "GET" -Url "$base/api/events"
$results += Invoke-CurlTest -Name "GET /api/users (no token)" -Method "GET" -Url "$base/api/users"

$results += Invoke-CurlTest -Name "GET /api/users" -Method "GET" -Url "$base/api/users" -Headers $authHeaders
$results += Invoke-CurlTest -Name "GET /api/users/me" -Method "GET" -Url "$base/api/users/me" -Headers $authHeaders
$updateMePayload = @{ name = "Updated $name" } | ConvertTo-Json -Compress
$results += Invoke-CurlTest -Name "PUT /api/users/me" -Method "PUT" -Url "$base/api/users/me" -Headers $authHeaders -Body $updateMePayload

if ($userId) {
  $results += Invoke-CurlTest -Name "GET /api/users/{id}" -Method "GET" -Url "$base/api/users/$userId" -Headers $authHeaders
  $updateUserPayload = @{ name = "Updated By ID $name" } | ConvertTo-Json -Compress
  $results += Invoke-CurlTest -Name "PUT /api/users/{id}" -Method "PUT" -Url "$base/api/users/$userId" -Headers $authHeaders -Body $updateUserPayload
}

$eventPayload = @{
  title = "Demo Event $ts"
  date = (Get-Date -Format "yyyy-MM-dd")
  startTime = "09:00"
  endTime = "10:00"
  location = "Kampus"
  description = "Uji coba"
} | ConvertTo-Json -Compress
$results += Invoke-CurlTest -Name "POST /api/events" -Method "POST" -Url "$base/api/events" -Headers $authHeaders -Body $eventPayload

$eventsResult = Invoke-CurlTest -Name "GET /api/events" -Method "GET" -Url "$base/api/events" -Headers $authHeaders
$results += $eventsResult
$eventsObj = $null
try { $eventsObj = $eventsResult.response | ConvertFrom-Json } catch {}
$eventId = $null
if ($eventsObj -and $eventsObj.Count -gt 0) { $eventId = $eventsObj[0].id }

if ($eventId) {
  $results += Invoke-CurlTest -Name "GET /api/events/{id}" -Method "GET" -Url "$base/api/events/$eventId" -Headers $authHeaders
  $updateEventPayload = @{
    title = "Updated Event $ts"
    date = (Get-Date -Format "yyyy-MM-dd")
    startTime = "10:00"
    endTime = "11:00"
    location = "Ruang 1"
    description = "Update"
  } | ConvertTo-Json -Compress
  $results += Invoke-CurlTest -Name "PUT /api/events/{id}" -Method "PUT" -Url "$base/api/events/$eventId" -Headers $authHeaders -Body $updateEventPayload
  $results += Invoke-CurlTest -Name "DELETE /api/events/{id}" -Method "DELETE" -Url "$base/api/events/$eventId" -Headers $authHeaders
}

$results += Invoke-CurlTest -Name "DELETE /api/users/me" -Method "DELETE" -Url "$base/api/users/me" -Headers $authHeaders

$lines = @()
$lines += "# API Test Results"
$lines += ""
$lines += "Base URL: $base"
$lines += "Test time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += ""

foreach ($r in $results) {
  $lines += "## $($r.name)"
  $lines += ""
  $lines += "- Method: $($r.method)"
  $lines += "- URL: $($r.url)"
  $lines += "- Status: $($r.status)"
  $lines += ""
  $lines += "Payload:"
  if ([string]::IsNullOrWhiteSpace($r.payload)) {
    $lines += '```'
    $lines += '<none>'
    $lines += '```'
  } else {
    $lines += '```'
    $lines += $r.payload
    $lines += '```'
  }
  $lines += ""
  $lines += "Response:"
  $respText = $r.response
  if ($respText -and $respText.Length -gt 2000) { $respText = $respText.Substring(0, 2000) + "..." }
  if ([string]::IsNullOrWhiteSpace($respText)) { $respText = "<empty>" }
  $lines += '```'
  $lines += $respText
  $lines += '```'
  $lines += ""
}

$lines | Set-Content "$PSScriptRoot\\..\\TEST.md"
