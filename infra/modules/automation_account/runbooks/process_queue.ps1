param (
    [string]$QueueName,
    [string]$StorageAccountName
)

Write-Output "Authenticating using Managed Identity..."
Connect-AzAccount -Identity

$ctx = (Get-AzStorageAccount -Name $StorageAccountName).Context

Write-Output "Checking queue for messages..."
$messages = Get-AzStorageQueueMessage `
    -Queue $QueueName `
    -Context $ctx `
    -MaxMessageCount 1

if (-not $messages) {
    Write-Output "No messages found."
    return
}

$message = $messages[0]
$payload = $message.MessageText | ConvertFrom-Json

Write-Output "Processing request for UPN: $($payload.userPrincipalName)"

Write-Output "Simulating user provisioning..."
Start-Sleep -Seconds 2

Remove-AzStorageQueueMessage `
    -Queue $QueueName `
    -Context $ctx `
    -MessageId $message.MessageId `
    -PopReceipt $message.PopReceipt

Write-Output "Message processed successfully."
