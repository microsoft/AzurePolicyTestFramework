terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
    type = string
}
variable "vnet_name" {
    type = string
}

data "azurerm_subnet" "example" {
  name                 = "deployedByPolicy"
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}