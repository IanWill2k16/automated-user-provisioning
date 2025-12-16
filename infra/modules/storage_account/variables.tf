variable "resource_group_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "storage_account_name" {
  type        = string
}

variable "queue_name" {
  type        = string
}

output "access_key" {
  value = azurerm_storage_account.sa.primary_access_key
}

output "id" {
  value = azurerm_storage_account.sa.id
}

output "blob_endpoint" {
  value = azurerm_storage_account.sa.primary_blob_endpoint
}

output "code_container_name" {
  value = azurerm_storage_container.code.name
}
