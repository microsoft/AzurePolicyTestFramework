resource "azurerm_policy_definition" "Enforce_virtual_machine_scale_set_naming_convention" {
  name         = "Enforce virtual_machine_scale_set naming convention${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce virtual_machine_scale_set naming convention${var.suffix}"
  description  = "Ensures a VM Scale Set name starts with vmss-"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.Compute/virtualMachineScaleSets"
          },
          {
            "field" : "name",
            "notLike" : "vmss-*"
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
