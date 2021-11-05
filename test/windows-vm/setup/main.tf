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

resource "random_string" "suffix" {
  length  = 5
  number  = false
  upper   = false
  special = false
}

module "policy" {
  source = "../../../policy_definitions/windows-vm"
  suffix = random_string.suffix.result
}

resource "azurerm_policy_assignment" "test" {
  name                 = "ci-deny-windows-vm-policy-assignment"
  policy_definition_id = module.policy.policy_id
  scope                = azurerm_resource_group.test.id
}

resource "azurerm_resource_group" "test" {
  location = "northeurope"
  name     = "rg-ci-deny-windows-vm-policy-test-${random_string.suffix.result}"
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "policy_assignment_name" {
  value = azurerm_policy_assignment.test.name
}
