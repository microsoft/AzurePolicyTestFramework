provider "azurerm" {
  version = "=2.39.0"
  features {}
}

provider "random" {
  version = "=3.0.0"
}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 5
  number  = false
  upper   = false
  special = false
}

module "policy" {
  source = "../../../policy_definitions/diskencryptionset-naming"
  suffix = random_string.suffix.result
}

resource "azurerm_policy_assignment" "test" {
  name                 = "ci-enforce-disk-encryption-set-naming-policy-assignment"
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
  name     = "rg-ci-policy-disk-encryption-set-naming-test-${random_string.suffix.result}"
}

resource "azurerm_key_vault" "test" {
  location                    = "northeurope"
  name                        = "kvt-ci-des-${random_string.suffix.result}"
  resource_group_name         = azurerm_resource_group.test.name
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  soft_delete_enabled         = true
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_access_policy" "pipeline-user" {
  key_vault_id = azurerm_key_vault.test.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "get",
    "create",
    "delete"
  ]
}

resource "azurerm_key_vault_key" "test" {
  name         = "des-test-key-${random_string.suffix.result}"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048

  depends_on = [
    azurerm_key_vault_access_policy.pipeline-user
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "policy_assignment_name" {
  value = azurerm_policy_assignment.test.name
}

output "keyvault_key_id" {
  value = azurerm_key_vault_key.test.id
}
