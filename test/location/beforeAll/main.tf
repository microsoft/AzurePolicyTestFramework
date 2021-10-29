provider "azurerm" {
  version = "=2.39.0"
  features {}
}

provider "random" {
  version = "=3.0.0"
}

resource "random_string" "suffix" {
  length  = 5
  number  = false
  upper   = false
  special = false
}

module "policy" {
  source = "../../../custom_policies/location"
  suffix = random_string.suffix.result
}

resource "azurerm_policy_assignment" "test" {
  name                 = "ci-enforce-location-policy-assignment"
  policy_definition_id = module.policy.policy_id
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
  name     = "rg-ci-policy-location-test-${random_string.suffix.result}"
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "policy_assignment_name" {
  value = azurerm_policy_assignment.test.name
}
