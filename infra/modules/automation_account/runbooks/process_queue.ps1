Write-Output "Authenticating using Managed Identity..."
Connect-AzAccount -Identity

$queueName          = Get-AutomationVariable -Name "queue_name"
$storageAccountName = Get-AutomationVariable -Name "storage_account_name"

Write-Output "Creating storage context via RBAC..."
$ctx = New-AzStorageContext `
    -StorageAccountName $storageAccountName `
    -UseConnectedAccount

$queue = Get-AzStorageQueue -Name $queueName -Context $ctx

Write-Output "Polling queue '$queueName' for messages..."
$message = $queue.QueueClient.ReceiveMessage()

if (-not $message) {
    Write-Output "No messages found. Exiting runbook."
    return
}

$messageText = $message.value.messageText

try {
    $decoded = [System.Text.Encoding]::UTF8.GetString(
        [System.Convert]::FromBase64String($messageText)
    )
    $payload = $decoded | ConvertFrom-Json
}
catch {
    try {
        $payload = $messageText | ConvertFrom-Json
    }
    catch {
        Write-Error "Failed to parse queue message JSON. Abandoning message."
        return
    }
}

$requiredFields = @("requestId", "userPrincipalName", "displayName")
$missingFields = $requiredFields | Where-Object { -not $payload.PSObject.Properties.Name.Contains($_) }

if ($missingFields) {
    Write-Error "Missing required fields: $($missingFields -join ', ')"
    return
}

Write-Output "=== Provisioning Request ==="
Write-Output "Request ID : $($payload.requestId)"
Write-Output "UPN        : $($payload.userPrincipalName)"
Write-Output "Display    : $($payload.displayName)"
Write-Output "============================"

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
Write-Output "Ticket: $($payload.requestId)"
Write-Output "Result: $provisioningResult"

$queue.QueueClient.DeleteMessage($message.Value.MessageId, $message.Value.PopReceipt)

Write-Output "Message processed and removed from queue successfully."
