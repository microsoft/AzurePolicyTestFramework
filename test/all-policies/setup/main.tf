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

resource "azurerm_policy_definition" "policy" {
  for_each = { for file in fileset(path.module, "../../../policy_definitions/*.json") : file => jsondecode(file(file)) }

  name         = "${each.value.properties.name} ${random_string.suffix.result}"
  policy_type  = each.value.properties.policyType
  mode         = each.value.properties.mode
  display_name = "${each.value.properties.displayName} ${random_string.suffix.result}"
  policy_rule  = jsonencode(each.value.properties.policyRule)
  parameters   = jsonencode(each.value.properties.parameters)
  description  = each.value.properties.description
  metadata     = jsonencode(each.value.properties.metadata)
}

resource "azurerm_policy_assignment" "test" {
  for_each = azurerm_policy_definition.policy

  name                 = each.value.name
  policy_definition_id = each.value.id
  scope                = azurerm_resource_group.test.id

  parameters = can(each.value.properties.parameters.effect) ? jsonencode(
    {
      "effect" : {
        "value" : "Deny"
      }
    }
  ) : ""
}

resource "azurerm_resource_group" "test" {
  location = "northeurope"
  name     = "policy-test-full-${random_string.suffix.result}"
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}
