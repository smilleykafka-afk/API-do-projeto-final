param([string]$BaseUrl = 'http://localhost:8000/api', [switch]$CleanupTestEmployee)
$ErrorActionPreference = 'Stop'
if ($CleanupTestEmployee -and $BaseUrl -ne 'http://localhost:8000/api') { throw 'Employee cleanup is only supported for the local Docker API.' }
$suffix = [guid]::NewGuid().ToString('N')
$password = [guid]::NewGuid().ToString('N')
$email = "docker-$suffix@example.com"
$headers = @{ Accept = 'application/json' }
function Request($Method, $Path, $Body = $null) {
    $params = @{ Method = $Method; Uri = "$BaseUrl$Path"; Headers = $headers }
    if ($null -ne $Body) {
        $params.ContentType = 'application/json'
        $params.Body = $Body | ConvertTo-Json -Depth 10
    }
    Invoke-RestMethod @params
}
$customer = $null
$device = $null
$order = $null
try {
    $session = Request Post '/register' @{name='Docker smoke test';email=$email;password=$password;password_confirmation=$password;role='admin'}
    if ($session.user.role -ne 'employee') { throw 'Public registration allowed privilege escalation.' }
    $headers.Authorization = "Bearer $($session.token)"
    $profile = Request Get '/profile'
    if ($profile.email -ne $email) { throw 'Profile does not match registered user.' }
    $customer = Request Post '/clientes' @{name="Docker $suffix";phone='41999999999'}
    $device = Request Post '/aparelhos' @{brand='Samsung';model='Docker test'}
    if ($null -ne $device.cliente_id -or $null -ne $device.imei) { throw 'Device should allow omitted customer and IMEI.' }
    $orderBody = @{aparelho_id=$device.id;assigned_to=$profile.id;problem='Smoke test';status='received';price=250}
    $order = Request Post '/ordens-servico' $orderBody
    $device = Request Put "/aparelhos/$($device.id)" @{cliente_id=$customer.id;brand='Samsung';model='Docker test'}
    if ($device.cliente_id -ne $customer.id) { throw 'Customer assignment failed.' }
    $device = Request Put "/aparelhos/$($device.id)" @{cliente_id=$null;brand='Samsung';model='Docker test'}
    if ($null -ne $device.cliente_id) { throw 'Customer unlink failed.' }
    $orderBody.status = 'completed'
    $updated = Request Put "/ordens-servico/$($order.id)" $orderBody
    if ($updated.status -ne 'completed' -or $updated.history.Count -ne 2) { throw 'Repair status or history was not saved.' }
    $null = Request Get '/dashboard'
    Write-Output 'PASS: registration, employee role, bearer authentication, profile, optional device customer, customer assignment/unlink, order, status history and dashboard.'
} finally {
    # Remove only records created by this run, in dependency order.
    if ($order) { $null = Request Delete "/ordens-servico/$($order.id)" }
    if ($device) { $null = Request Delete "/aparelhos/$($device.id)" }
    if ($customer) { $null = Request Delete "/clientes/$($customer.id)" }
    if ($headers.Authorization) { $null = Request Post '/logout' @{} }
    if ($CleanupTestEmployee -and $session) {
        Push-Location (Join-Path $PSScriptRoot '..')
        try {
            docker compose exec -T api php tools/cleanup_test_employee.php "$($session.user.id)" $email
            if ($LASTEXITCODE -ne 0) { throw 'Temporary employee cleanup failed.' }
        } finally { Pop-Location }
    }
}
if ($CleanupTestEmployee) { Write-Output 'Temporary employee and business records removed; token revoked.' }
else { Write-Output "Created test employee: $email (logged out). Business test records removed." }
