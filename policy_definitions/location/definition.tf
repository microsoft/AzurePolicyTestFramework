locals {
  file         = jsondecode(file("${path.module}/policy.json"))
  name         = "${local.file.name}${var.suffix}"
  policy_type  = local.file.properties.policyType
  mode         = local.file.properties.mode
  display_name = "${local.file.properties.displayName}${var.suffix}"
  description  = local.file.properties.description
  rule         = jsonencode(local.file.properties.policyRule)
  parameters   = jsonencode(local.file.properties.parameters)
  metadata     = jsonencode(local.file.properties.metadata)
}

resource "azurerm_policy_definition" "policy" {
  name         = local.name
  policy_type  = local.policy_type
  mode         = local.mode
  display_name = local.display_name
  policy_rule  = local.rule
  parameters   = local.parameters
}

output "policy_id" {
  value = azurerm_policy_definition.policy.id
}
