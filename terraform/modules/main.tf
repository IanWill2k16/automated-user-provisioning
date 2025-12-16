module "resource_group" {
  source   = "./modules/resource_group"
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
}
