resource "azurerm_application_insights" "this" {
  name                = "${var.project_name}-${var.environment}-appi"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  application_type    = "web"
}

module "resource_group" {
  source   = "./modules/resource_group"
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
}

module "storage" {
  source = "./modules/storage"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  storage_account_name = lower(replace("${var.project_name}${var.environment}sa", "-", ""))
  queue_name = "provisioning-requests"
}

module "function_app" {
  source = "./modules/function_app"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  function_app_name = "${var.project_name}-${var.environment}-fn"

  storage_account_name             = module.storage.storage_account_name
  app_insights_connection_string   = azurerm_application_insights.this.connection_string
}

module "automation_account" {
  source              = "./modules/automation_account"
  name_prefix         = var.name_prefix
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

