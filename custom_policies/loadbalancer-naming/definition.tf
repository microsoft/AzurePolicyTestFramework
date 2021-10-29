resource "azurerm_policy_definition" "Enforce_network_load_balancer_naming_convention" {
  name         = "Enforce network_load_balancer naming convention${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce network_load_balancer naming convention${var.suffix}"
  description  = "Ensures a Network Load Balancer name starts with ilb-"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.Network/loadBalancers"
          },
          {
            "field" : "name",
            "notLike" : "lb-*"
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
