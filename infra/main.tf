resource "azurerm_application_insights" "this" {
  name                = "${var.name_prefix}-appi"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  application_type    = "web"
}

module "resource_group" {
  source   = "./modules/resource_group"
  name     = "${var.name_prefix}-rg"
  location = var.location
}

module "storage" {
  source = "./modules/storage_account"
  storage_account_name = lower(replace("${var.name_prefix}sa", "-", ""))
  location            = var.location
  resource_group_name = module.resource_group.name
  queue_name = "provisioning-requests"
}

module "function_app" {
  source = "./modules/function_app"
  function_app_name = "${var.name_prefix}-fn"
  resource_group_name = module.resource_group.name
  location            = var.location
  storage_account_name             = module.storage.storage_account_name
  app_insights_connection_string   = azurerm_application_insights.this.connection_string
  storage_access_key    = module.storage.access_key
  storage_blob_endpoint = module.storage.blob_endpoint
  code_container_name   = module.storage.code_container_name
  storage_account_id    = module.storage.storage_account_id
  queue_name            = module.storage.queue_name
}

module "automation_account" {
  source              = "./modules/automation_account"
  automation_account_name = "${var.name_prefix}-aa"
  location            = var.location
  resource_group_name = module.resource_group.name
  storage_account_id  = module.storage.storage_account_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  queue_name          = module.storage.queue_name
  storage_account_name = module.storage.storage_account_name
}

module "monitoring" {
  source              = "./modules/monitoring"
  analytics_name      = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = module.resource_group.name
}


