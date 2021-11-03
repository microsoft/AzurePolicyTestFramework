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

variable "prefix" { type = string }

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
