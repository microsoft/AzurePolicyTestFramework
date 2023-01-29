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

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "westeurope"
}

output "resource_group_name" {
    value = azurerm_resource_group.example.name
}

output "location" {
    value = azurerm_resource_group.example.location
}