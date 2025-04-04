# Check.ps1
# Description: Verifies if Peer Networking Grouping (p2psvc) is Disabled.

# Define registry path and value
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\p2psvc"
$regValue = "Start"
$expectedValue = 4

# Check if the registry path exists
if (Test-Path -Path $regPath) {
    $currentValue = Get-ItemProperty -Path $regPath -Name $regValue -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regValue

    if ($currentValue -eq $expectedValue) {
        Write-Host "PASS: Peer Networking Grouping (p2psvc) is Disabled (`Start` = 4)." -ForegroundColor Green
    } else {
        Write-Host "FAIL: Peer Networking Grouping (p2psvc) is not set to Disabled (`Start` = 4). Current Value: $currentValue" -ForegroundColor Red
    }
} else {
    Write-Host "PASS: Peer Networking Grouping (p2psvc) is not installed." -ForegroundColor Green
}
