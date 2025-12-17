param (
    [Parameter(Mandatory)]
    [string]$QueueName,

    [Parameter(Mandatory)]
    [string]$StorageAccountName
)

Write-Output "Authenticating to Azure using Managed Identity..."
Connect-AzAccount -Identity -ErrorAction Stop

$storageAccount = Get-AzStorageAccount -Name $StorageAccountName -ErrorAction Stop
$ctx = $storageAccount.Context

Write-Output "Polling queue '$QueueName' for messages..."
$messages = Get-AzStorageQueueMessage `
    -Queue $QueueName `
    -Context $ctx `
    -MaxMessageCount 1

if (-not $messages) {
    Write-Output "No messages found. Exiting runbook."
    return
}

$message = $messages[0]

try {
    $payload = $message.MessageText | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse queue message JSON. Abandoning message."
    return
}

$requiredFields = @("ticketId", "userPrincipalName", "displayName")
$missingFields = $requiredFields | Where-Object { -not $payload.PSObject.Properties.Name.Contains($_) }

if ($missingFields) {
    Write-Error "Missing required fields: $($missingFields -join ', ')"
    return
}

Write-Output "Processing ticket [$($payload.ticketId)]"
Write-Output "Target UPN: $($payload.userPrincipalName)"
Write-Output "Display Name: $($payload.displayName)"

try {
    Write-Output "Starting user provisioning operation..."

    # Placeholder for Microsoft Graph logic

    Start-Sleep -Seconds 2

    $provisioningResult = "Success"
}
catch {
    Write-Error "Provisioning failed: $_"
    $provisioningResult = "Failed"
}

Write-Output "Posting result back to Jira (simulated)"
Write-Output "Ticket: $($payload.ticketId)"
Write-Output "Result: $provisioningResult"

Remove-AzStorageQueueMessage `
    -Queue $QueueName `
    -Context $ctx `
    -MessageId $message.MessageId `
    -PopReceipt $message.PopReceipt

Write-Output "Message processed and removed from queue successfully."
