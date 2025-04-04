# Remedi.ps1
# Description: Disables the Print Spooler (Spooler) service by setting the registry value to 4.

# Define registry path and value
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Spooler"
$regValue = "Start"
$disableValue = 4

# Check if the service is installed
if (Test-Path -Path $regPath) {
    try {
        # Set the registry value to disable the service
        Set-ItemProperty -Path $regPath -Name $regValue -Value $disableValue
        Write-Host "SUCCESS: Print Spooler service has been disabled (`Start` = 4)." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to disable Print Spooler service. $_" -ForegroundColor Red
    }
} else {
    Write-Host "INFO: Print Spooler service is not installed. No action required." -ForegroundColor Yellow
}
