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
  file = jsondecode(file("${path.module}/../../../policy_definitions/resource-group-naming.json"))
}

resource "azurerm_policy_definition" "policy" {
  name         = "${local.file.name} ${random_string.suffix.result}"
  policy_type  = local.file.properties.policyType
  mode         = local.file.properties.mode
  display_name = "${local.file.properties.displayName} ${random_string.suffix.result}"
  policy_rule  = jsonencode(local.file.properties.policyRule)
  parameters   = jsonencode(local.file.properties.parameters)
  description  = local.file.properties.description
  metadata     = jsonencode(local.file.properties.metadata)
}

data "azurerm_subscription" "current" {}

resource "azurerm_policy_assignment" "test" {
  name                 = "assign-resourcegroup-naming-policy"
  policy_definition_id = azurerm_policy_definition.policy.id
  scope                = data.azurerm_subscription.current.id

  parameters = jsonencode(
    {
      "effect" : {
        "value" : "Deny"
      }
  })
}
