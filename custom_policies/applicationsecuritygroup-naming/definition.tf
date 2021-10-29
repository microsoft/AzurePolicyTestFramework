resource "azurerm_policy_definition" "Enforce_application_security_group_naming_convention" {
  name         = "Enforce application_security_group naming convention${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce application_security_group naming convention${var.suffix}"
  description  = "Ensures an Application Security Group name starts with asg-"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.Network/applicationSecurityGroups"
          },
          {
            "field" : "name",
            "notLike" : "asg-*"
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
