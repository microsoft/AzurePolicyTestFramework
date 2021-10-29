resource "azurerm_policy_definition" "Enforce_storage_account_naming_convention" {
  name         = "Enforce storage account naming convention${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce storage account naming convention${var.suffix}"
  description  = "Ensures a Storage Account name starts with sa"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.Storage/storageAccounts"
          },
          {
            "field" : "name",
            "notLike" : "sa*"
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
