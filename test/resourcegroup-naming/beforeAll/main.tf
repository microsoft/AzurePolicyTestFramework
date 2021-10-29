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
  source = "../../../custom_policies/resourcegroup-naming"
  suffix = random_string.suffix.result
}

data "azurerm_subscription" "current" {}

resource "azurerm_policy_assignment" "test" {
  name                 = "ci-enforce-resourcegroup-naming-policy-assignment"
  policy_definition_id = module.policy.policy_id
  scope                = data.azurerm_subscription.current.id

  parameters = jsonencode(
    {
      "effect" : {
        "value" : "Deny"
      }
  })
}

output "policy_assignment_name" {
  value = azurerm_policy_assignment.test.name
}
