resource "azurerm_policy_definition" "Enforce_virtual_network_naming_convention" {
  name         = "Enforce virtual_network naming convention${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce virtual_network naming convention${var.suffix}"
  description  = "Ensures a Virtual Network name starts with vnet-"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.Network/virtualNetworks"
          },
          {
            "field" : "name",
            "notLike" : "vnet-*"
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
        }
        "allowedValues" : [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "defaultValue" : "Audit"
      }
  })
}
