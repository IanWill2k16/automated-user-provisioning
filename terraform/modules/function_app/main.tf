resource "azurerm_service_plan" "this" {
  name                = "${var.function_app_name}-fc-plan"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name = "FC1"
  os_type  = "Linux"
}

resource "azurerm_function_app_flex_consumption" "this" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  identity {
    type = "SystemAssigned"
  }

  runtime_name    = "python"
  runtime_version = "3.11"

  app_settings = {
    FUNCTIONS_EXTENSION_VERSION           = "~4"
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_insights_connection_string
  }
}

resource "azurerm_role_assignment" "queue_sender" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_function_app_flex_consumption.func.identity[0].principal_id
}
