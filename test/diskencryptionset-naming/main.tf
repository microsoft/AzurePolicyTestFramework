provider "azurerm" {
  version = "=2.39.0"
  features {}
}

provider "random" {
  version = "=3.0.0"
}

variable "prefix" {}
variable "resource_group_name" {}
variable "keyvault_key_id" {}

resource "random_string" "suffix" {
  length  = 5
  number  = false
  upper   = false
  special = false
}

resource "azurerm_disk_encryption_set" "test" {
  key_vault_key_id    = var.keyvault_key_id
  location            = "northeurope"
  name                = "${var.prefix}${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }
}
