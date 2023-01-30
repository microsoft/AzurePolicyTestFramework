resource "random_string" "suffix" {
  length  = 5
  numeric  = false
  upper   = false
  special = false
}



resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "rg-terratest-policy-${var.name}-${random_string.suffix.result}"
}

module "policy_set" {
  source = "../../module"
  name = var.name
}