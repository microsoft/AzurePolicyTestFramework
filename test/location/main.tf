provider "azurerm" {
  version = "=2.39.0"
  features {}
}

provider "random" {
  version = "=3.0.0"
}

variable "resource_group_name" {}
variable "location" {}

resource "random_string" "suffix" {
  length  = 5
  number  = false
  upper   = false
  special = false
}

resource "azurerm_virtual_network" "test" {
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  name                = "vnet-ci-test-location-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
}

output "resource_id" {
  value = azurerm_virtual_network.test.id
}
