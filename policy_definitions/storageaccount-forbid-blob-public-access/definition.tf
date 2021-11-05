resource "azurerm_policy_definition" "Enforce_storage_account_forbid_blob_public_access" {
  name         = "Enforce storage account forbid blob public access${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Forbid blob public acess should be enabled${var.suffix}"
  description  = "Ensures that blob public access is not allowed"
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.Storage/storageAccounts"
          },
          {
            "not" : {
              "field" : "Microsoft.Storage/storageAccounts/allowBlobPublicAccess",
              "equals" : "false"
            }
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
          "description" : "The effect determines what happens when the policy rule is evaluated to match"
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
