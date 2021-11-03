terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.63.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" { type = string}
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
