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

variable "tls_version" {}
variable "resource_group_name" { type = string}

resource "random_string" "suffix" {
  length  = 5
  number  = false
  upper   = false
  special = false
}

resource "azurerm_storage_account" "test" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = "northeurope"
  name                     = "minumumtls12${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  min_tls_version          = var.tls_version
}
