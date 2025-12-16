output "automation_account_id" {
  value = azurerm_automation_account.this.id
}

output "automation_account_name" {
  value = azurerm_automation_account.this.name
}

output "principal_id" {
  value = azurerm_automation_account.this.identity[0].principal_id
}
