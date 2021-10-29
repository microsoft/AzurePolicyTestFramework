resource "azurerm_policy_definition" "Enforce_subnet_naming_convention" {
  name         = "Enforce subnet naming convention${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce subnet naming convention${var.suffix}"
  description  = "Ensures a Subnet name starts with snet-"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.Network/virtualNetworks/subnets"
          },
          {
            "field" : "name",
            "notLike" : "snet-*"
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
