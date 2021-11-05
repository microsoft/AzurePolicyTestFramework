resource "azurerm_policy_definition" "Enforce_managed_identities_naming_convention" {
  name         = "Enforce managed identities naming convention${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce managed identities naming convention${var.suffix}"
  description  = "Ensures a Managed Identity name starts with mi-"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.ManagedIdentity/userAssignedIdentities"
          },
          {
            "field" : "name",
            "notLike" : "mi-*"
          }
        ]
      },
      "then" : {
        "effect" : "[parameters('effect')]"
      }
  })

  parameters = jsonencode(
    {
      "effect" : {
        "type" : "String",
        "metadata" : {
          "displayName" : "Effect",
          "description" : "Enable or disable or change the execution of this policy"
        },
        "allowedValues" : [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "defaultValue" : "Audit"
      }
  })
}
