resource "azurerm_policy_definition" "Prevent_Windows_VM_deployment" {
  name         = "Prevent Windows VM deployment${var.suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Prevent Windows VM deployment${var.suffix}"
  description  = "Ensures that Windows VMs are not allowed"
  policy_rule = jsonencode(
    {
      "if" : {
        "anyOf" : [
          {
            "allOf" : [
              {
                "field" : "type",
                "equals" : "Microsoft.Compute/virtualMachineScaleSets"
              },
              {
                "field" : "Microsoft.Compute/virtualMachineScaleSets/virtualMachineProfile.osProfile.windowsConfiguration",
                "exists" : "True"
              }
            ]
          },
          {
            "allOf" : [
              {
                "field" : "type",
                "equals" : "Microsoft.Compute/virtualMachines"
              },
              {
                "field" : "Microsoft.Compute/virtualMachines/osProfile.windowsConfiguration",
                "exists" : "True"
              }
            ]
          }
        ]
      },
      "then" : {
        "effect" : "deny"
      }
  })
}
