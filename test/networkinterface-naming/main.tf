provider "azurerm" {
  version = "=2.39.0"
  features {}
}

provider "random" {
  version = "=3.0.0"
}

variable "resource_group_name" {}
variable "prefix" {}
variable "subnet_id" {}

resource "random_string" "suffix" {
  length  = 5
  number  = false
  upper   = false
  special = false
}

resource "azurerm_network_interface" "test" {
  location            = "northeurope"
  name                = "${var.prefix}${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "test"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }
}
