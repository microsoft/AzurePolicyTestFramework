variable "name" {
    type = string
    description = "Policy test name"
    default = "policy-test"
}

variable "location" {
    type = string
    description = "resource group location"
    default = "westeurope"
}

variable "policy_rule_definition" {
    type = string
    description = "Path to policy rule definition file"
}

variable "policy_params_definition" {
    type = string
    description = "Path to policy params definition file"
}

variable "policy_params_values" {
    type = string
    description = "Parameter values to apply in the policy assignment"
}

variable "role_id" {
    type = string
    default = "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
    description = "Role ID to assign to policy"
}