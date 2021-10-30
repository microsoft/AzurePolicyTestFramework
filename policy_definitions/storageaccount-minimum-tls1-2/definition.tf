resource "azurerm_policy_definition" "Enforce_storage_account_minimum_tls1_2" {
  name         = "Enforce storage account minimum tls version${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce storage account minimum tls version${var.suffix}"
  description  = "Ensures that secure transfer is enabled for Storage Account"
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
              "field" : "Microsoft.Storage/storageAccounts/minimumTlsVersion",
              "equals" : "TLS1_2"
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
