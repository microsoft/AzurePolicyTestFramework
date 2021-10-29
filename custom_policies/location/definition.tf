resource "azurerm_policy_definition" "Prevent_from_bad_location" {
  name         = "Prevent from bad location${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Prevent from bad location${var.suffix}"

  policy_rule = jsonencode(
    {
      "if" : {
        "not" : {
          "field" : "location",
          "in" : "[parameters('allowedLocations')]"
        }
      },
      "then" : {
        "effect" : "[parameters('effect')]"
      }
  })

  parameters = jsonencode(
    {
      "allowedLocations" : {
        "type" : "Array",
        "defaultValue" : ["North Europe", "---", "East US 2"],
        "metadata" : {
          "description" : "The list of allowed locations for resources.",
          "displayName" : "Allowed locations",
          "strongType" : "location"
        }
      },
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
