# Check.ps1
# Description: Verifies if the Windows PushToInstall Service (PushToInstall) is set to Disabled.

# Define registry path and value
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\PushToInstall"
$regValue = "Start"
$expectedValue = 4

# Check if the registry path exists
if (Test-Path -Path $regPath) {
    $currentValue = Get-ItemProperty -Path $regPath -Name $regValue -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regValue

    if ($currentValue -eq $expectedValue) {
        Write-Host "PASS: Windows PushToInstall Service (PushToInstall) is Disabled (`Start` = 4)." -ForegroundColor Green
    } else {
        Write-Host "FAIL: Windows PushToInstall Service (PushToInstall) is not set to Disabled. Current Value: $currentValue" -ForegroundColor Red
    }
} else {
    Write-Host "INFO: Windows PushToInstall Service (PushToInstall) registry key does not exist. The service may not be installed." -ForegroundColor Yellow
}