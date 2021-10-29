provider "azurerm" {
  version = "=2.39.0"
  features {}
}

provider "random" {
  version = "=3.0.0"
}

variable "prefix" {}
variable "resource_group_name" {}

resource "random_string" "suffix" {
  length  = 5
  number  = false
  upper   = false
  special = false
}

resource "azurerm_virtual_network" "test" {
  address_space       = ["10.0.0.0/16"]
  location            = "northeurope"
  name                = "${var.prefix}${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
}
