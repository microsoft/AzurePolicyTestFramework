resource "azurerm_policy_definition" "Enforce_resource_group_naming_naming_convention" {
  name         = "Enforce resource_group_naming naming convention${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce resource_group_naming naming convention${var.suffix}"
  description  = "Ensures a Resource Group name starts with rg-"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "in" : [
              "Microsoft.Resources/subscriptions/resourceGroups",
              "Microsoft.Resources/resourceGroups"
            ]
          },
          {
            "field" : "name",
            "notLike" : "rg-*"
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
