resource "azurerm_automation_account" "this" {
  name                = "${var.name_prefix}-aa"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
