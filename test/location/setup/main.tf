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

locals {
  file = jsondecode(file("${path.module}/../../../policy_definitions/location.json"))
}

resource "azurerm_policy_definition" "policy" {
  name         = "${local.file.properties.name} ${random_string.suffix.result}"
  policy_type  = local.file.properties.policyType
  mode         = local.file.properties.mode
  display_name = "${local.file.properties.displayName} ${random_string.suffix.result}"
  policy_rule  = jsonencode(local.file.properties.policyRule)
  parameters   = jsonencode(local.file.properties.parameters)
  description  = local.file.properties.description
  metadata     = jsonencode(local.file.properties.metadata)
}

resource "azurerm_policy_assignment" "test" {
  name                 = "assign-location-policy"
  policy_definition_id = azurerm_policy_definition.policy.id
  scope                = azurerm_resource_group.test.id

  parameters = jsonencode(
    {
      "effect" : {
        "value" : "Deny"
      }
  })
}

resource "azurerm_resource_group" "test" {
  location = "northeurope"
  name     = "test-policy-location-${random_string.suffix.result}"
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}
