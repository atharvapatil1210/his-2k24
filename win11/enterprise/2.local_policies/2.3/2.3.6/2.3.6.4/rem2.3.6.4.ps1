# Title: Remediation Script for 'Domain member: Disable machine account password changes'
# Description: Configures the policy to 'Disabled' by setting the registry value.

Write-Host "Starting Remediation: Configuring 'Domain member: Disable machine account password changes' policy" -ForegroundColor Yellow

# Define the registry path and value
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
$regValueName = "DisablePasswordChange"
$desiredValue = 0

try {
    # Check if the registry path exists, and create it if it doesn't
    if (-not (Test-Path $regPath)) {
        Write-Host "Registry path not found. Creating $regPath..." -ForegroundColor Cyan
        New-Item -Path $regPath -Force | Out-Null
    }

    # Set the registry value
    Write-Host "Configuring registry value '$regValueName' to '$desiredValue'..." -ForegroundColor Cyan
    Set-ItemProperty -Path $regPath -Name $regValueName -Value $desiredValue -Type DWord

    # Verify the change
    $regValue = Get-ItemProperty -Path $regPath -Name $regValueName | Select-Object -ExpandProperty $regValueName
    if ($regValue -eq $desiredValue) {
        Write-Host "SUCCESS: 'Domain member: Disable machine account password changes' is now set to 'Disabled'." -ForegroundColor Green
    } else {
        Write-Host "FAIL: Unable to set 'Domain member: Disable machine account password changes' to 'Disabled'." -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: An error occurred during remediation. $_" -ForegroundColor Red
}

Write-Host "Remediation Completed." -ForegroundColor Yellow

