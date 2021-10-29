provider "azurerm" {
  version = "=2.39.0"
  features {}
}

provider "random" {
  version = "=3.0.0"
}

variable "prefix" {}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  number  = false
  special = false
}

resource "azurerm_resource_group" "test" {
  location = "northeurope"
  name     = "${var.prefix}${random_string.suffix.result}"
}
