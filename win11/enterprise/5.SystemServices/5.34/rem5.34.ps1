# Remedi.ps1
# Description: Disables the Windows Event Collector Service (Wecsvc) by setting the registry value to 4.

# Define registry path and value
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Wecsvc"
$regValue = "Start"
$disableValue = 4

# Check if the service is installed
if (Test-Path -Path $regPath) {
    try {
        # Disable the service by setting the registry value
        Set-ItemProperty -Path $regPath -Name $regValue -Value $disableValue
        Write-Host "SUCCESS: Windows Event Collector Service (Wecsvc) has been disabled (`Start` = 4)." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to disable Windows Event Collector Service (Wecsvc). $_" -ForegroundColor Red
    }
} else {
    Write-Host "INFO: Windows Event Collector Service (Wecsvc) registry key does not exist. The service may not be installed." -ForegroundColor Yellow
}