# check.ps1

# Define the subcategory for auditing
$subcategory = "Sensitive Privilege Use"

# Retrieve the current audit settings
$auditSettings = auditpol /get /subcategory:"$subcategory" 2>&1

if ($auditSettings -match "Success and Failure") {
    Write-Output "'Audit Sensitive Privilege Use' is correctly set to include 'Success and Failure'."
} else {
    Write-Output "'Audit Sensitive Privilege Use' is not configured as recommended. Current Output: $auditSettings"
}
