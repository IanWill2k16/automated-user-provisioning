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
