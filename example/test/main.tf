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
variable "location" {
    type = string
}

variable "address_space" { 
    type = list(string)
    default = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
}