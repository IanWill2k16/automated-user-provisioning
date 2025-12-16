terraform {
  backend "azurerm" {
    resource_group_name  = "identity-automation-tfstate-rg"
    storage_account_name = "identityautomationtf"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}