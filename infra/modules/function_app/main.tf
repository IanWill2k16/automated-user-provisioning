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

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${var.storage_blob_endpoint}${var.code_container_name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = var.storage_access_key

  runtime_name    = "python"
  runtime_version = "3.11"

  app_settings = {
    AzureWebJobsStorage                   = "DefaultEndpointsProtocol=https;AccountName=${var.storage_name};AccountKey=${var.storage_access_key};EndpointSuffix=core.windows.net"
    FUNCTIONS_EXTENSION_VERSION           = "~4"
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_insights_connection_string
  }

  site_config {}
}

resource "azurerm_role_assignment" "queue_sender" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_function_app_flex_consumption.this.identity[0].principal_id
}
