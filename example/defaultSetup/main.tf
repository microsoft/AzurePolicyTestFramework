resource "random_string" "suffix" {
  length  = 5
  numeric  = false
  upper   = false
  special = false
}


resource "azurerm_policy_definition" "policy" {
  name         = "${var.name}-${random_string.suffix.result}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "${var.name}-${random_string.suffix.result}"
  policy_rule  = file(var.policy_rule_definition)
  parameters   = file(var.policy_params_definition)
  description  = "Generated Automatically by terratest"
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "rg-terratest-policy-${var.name}-${random_string.suffix.result}"
}


resource "azurerm_resource_group_policy_assignment" "test" {
  name                 = "${var.name}-${random_string.suffix.result}"
  location = var.location
  description = "Generated Automatically by terratest"
  display_name = "${var.name}-${random_string.suffix.result}"
  identity {
    type = "SystemAssigned"
  }
  resource_group_id = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.policy.id
  parameters = var.policy_params_values

}

resource "azurerm_role_assignment" "assignment" {
  scope                = azurerm_resource_group.test.id
  role_definition_id = var.role_id
  principal_id         = azurerm_resource_group_policy_assignment.test.identity.0.principal_id
  depends_on = [azurerm_policy_definition.policy]
}
