# Title: Remediation Script for 'Impersonate a client after authentication' Policy
# Description: This script sets the 'Impersonate a client after authentication' policy to 'Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE' as per CIS recommendations.

Write-Host "Starting Remediation: Configuring 'Impersonate a client after authentication' policy" -ForegroundColor Yellow

try {
    # Export the current security policy configuration
    Write-Host "Exporting current security policy..." -ForegroundColor Cyan
    secedit /export /cfg "$env:TEMP\secedit-output.inf"

    # Load the exported policy configuration
    Write-Host "Reading exported policy configuration..." -ForegroundColor Cyan
    $policyContent = Get-Content "$env:TEMP\secedit-output.inf"

    # Update the policy for 'Impersonate a client after authentication' to the expected values
    Write-Host "Updating the policy to 'Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE'..." -ForegroundColor Cyan
    $updatedContent = $policyContent -replace '(?<=SeImpersonatePrivilege = ).*', '*S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6'

    # Save the updated policy
    Write-Host "Saving the updated policy configuration..." -ForegroundColor Cyan
    $updatedContent | Set-Content "$env:TEMP\secedit-updated.inf"

    # Apply the updated policy configuration
    Write-Host "Applying the updated security policy..." -ForegroundColor Cyan
    secedit /configure /db secedit.sdb /cfg "$env:TEMP\secedit-updated.inf" /areas USER_RIGHTS

    Write-Host "SUCCESS: 'Impersonate a client after authentication' policy is now configured to 'Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE'." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to configure the policy. $_" -ForegroundColor Red
}

Write-Host "Remediation Completed." -ForegroundColor Yellow

