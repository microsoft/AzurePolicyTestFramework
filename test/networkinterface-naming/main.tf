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
variable "prefix" { type = string }
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
