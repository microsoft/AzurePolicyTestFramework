provider "azurerm" {
  version = "=2.39.0"
  features {}
}

provider "random" {
  version = "=3.0.0"
}

variable "prefix" {}
variable "resource_group_name" {}
variable "subnet_id" {}

resource "random_string" "suffix" {
  length  = 5
  number  = false
  upper   = false
  special = false
}

resource "azurerm_lb" "test" {
  location            = "northeurope"
  name                = "${var.prefix}${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "ilb_pip"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}
