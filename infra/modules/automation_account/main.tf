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

  runbook_type = "PowerShell72"
  log_verbose  = true
  log_progress = true

  content = file("${path.module}/runbooks/process_queue.ps1")
}

resource "azurerm_monitor_diagnostic_setting" "automation" {
  name                       = "automation-diag"
  target_resource_id         = azurerm_automation_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "JobLogs"
  }

  enabled_log {
    category = "JobStreams"
  }
}

resource "azurerm_automation_module" "az_storage" {
  name                    = "Az.Storage"
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.Storage/9.4.0"
  }
}

# -------------------------------------------------------------------
# Runbook Schedule (INTENTIONALLY DISABLED)
#
# This schedule is commented out to avoid continuous execution costs.
# It is left here to demonstrate how the runbook would be triggered
# automatically in a production environment.
#
# Uncomment and apply to enable queue polling on a schedule.
# -------------------------------------------------------------------

# resource "azurerm_automation_schedule" "queue_poll" {
#   name                    = "poll-provisioning-queue"
#   resource_group_name     = var.resource_group_name
#   automation_account_name = azurerm_automation_account.this.name

#   frequency = "Hour"
#   interval  = 1
# }

# resource "azurerm_automation_job_schedule" "queue_poll" {
#   resource_group_name     = var.resource_group_name
#   automation_account_name = azurerm_automation_account.this.name
#   runbook_name            = azurerm_automation_runbook.queue_worker.name
#   schedule_name           = azurerm_automation_schedule.queue_poll.name

#   parameters = {
#     queuename          = var.queue_name
#     storageaccountname = var.storage_account_name
#   }
# }

# -------------------------------------------------------------------

resource "azurerm_automation_variable_string" "queue_name" {
  name                    = "queue_name"
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  value                   = var.queue_name
}

resource "azurerm_automation_variable_string" "storage_account_name" {
  name                    = "storage_account_name"
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  value                   = var.storage_account_name
}
