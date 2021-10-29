resource "azurerm_policy_definition" "Enforce_disk_encryption_set_naming_convention" {
  name         = "Enforce disk_encryption_set naming convention${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce disk_encryption_set naming convention${var.suffix}"
  description  = "Ensures a Disk Encryption Set name starts with des-"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.Compute/diskEncryptionSets"
          },
          {
            "field" : "name",
            "notLike" : "des-*"
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
