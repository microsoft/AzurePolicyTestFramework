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
  source = "../../../policy_definitions/loadbalancer-naming"
  suffix = random_string.suffix.result
}

resource "azurerm_policy_assignment" "test" {
  name                 = "ci-audit-loadbalancer-naming-policy-assignment"
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
  name     = "rg-ci-loadbalancer-naming-test-${random_string.suffix.result}"
}

resource "azurerm_virtual_network" "test" {
  address_space       = ["10.0.0.0/16"]
  location            = "northeurope"
  name                = "vnet-ci-loadbalancer-naming-test-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "snet-ci-loadbalancer-naming-test-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "policy_assignment_name" {
  value = azurerm_policy_assignment.test.name
}

output "subnet_id" {
  value = azurerm_subnet.test.id
}
