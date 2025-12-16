resource "azurerm_automation_account" "this" {
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "Basic"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "queue_receiver" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
}

resource "azurerm_automation_runbook" "queue_worker" {
  name                    = "process-queue"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  runbook_type = "PowerShell"
  log_verbose  = true
  log_progress = true

  content = file("${path.module}/runbooks/process-queue.ps1")
}

resource "azurerm_monitor_diagnostic_setting" "automation" {
  name                       = "automation-diag"
  target_resource_id         = azurerm_automation_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "JobLogs"
    enabled  = true
  }

  log {
    category = "JobStreams"
    enabled  = true
  }
}