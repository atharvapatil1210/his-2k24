# Title: CIS Control 19.7.8.1 (L1) - Remediate 'Configure Windows Spotlight on Lock Screen'

Write-Host "Remediating: CIS Control 19.7.8.1 (L1) - Configure Windows Spotlight on Lock Screen"

$registryBasePath = "HKU:\"
$regSubPath = "Software\Policies\Microsoft\Windows\CloudContent"
$regValueName = "ConfigureWindowsSpotlight"
$expectedValue = 2

# Get all user SIDs from the registry
$sidList = Get-ChildItem -Path $registryBasePath | Where-Object { $_.Name -match "^S-1-5-[0-9-]+$" }

if ($sidList) {
    foreach ($sid in $sidList) {
        $regPath = Join-Path -Path $sid.FullName -ChildPath $regSubPath
        if (-not (Test-Path -Path $regPath)) {
            Write-Host "Creating registry path for user SID $($sid.Name)..." -ForegroundColor Yellow
            New-Item -Path $regPath -Force | Out-Null
        }

        Set-ItemProperty -Path $regPath -Name $regValueName -Value $expectedValue
        Write-Host "Remediated for user SID $($sid.Name): 'Configure Windows Spotlight on Lock Screen' is now set to Disabled." -ForegroundColor Green
    }
} else {
    Write-Host "No user SIDs found in the registry." -ForegroundColor Yellow
}

