resource "azurerm_policy_definition" "Enforce_network_security_group_naming_convention" {
  name         = "Enforce network_security_group naming convention${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce network_security_group naming convention${var.suffix}"
  description  = "Ensures a Network Security Group name starts with nsg-"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.Network/networkSecurityGroups"
          },
          {
            "field" : "name",
            "notLike" : "nsg-*"
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
