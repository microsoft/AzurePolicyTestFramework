package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestAllowedLocationPolicy(t *testing.T) {
	t.Parallel()

	testCases := []PolicyTestCase{
		{configuration: "westeurope", errorExpected: true},
		{configuration: "westus", errorExpected: true},
		{configuration: "uksouth", errorExpected: true},
		{configuration: "francecentral", errorExpected: true},
		{configuration: "northeurope", errorExpected: false},
		{configuration: "eastus2", errorExpected: false},
	}

	beforeAllOptions := &terraform.Options{
		TerraformDir: "./location/beforeAll",
	}

	t.Cleanup(func() {
		terraform.Destroy(t, beforeAllOptions)
	})
	terraform.InitAndApply(t, beforeAllOptions)
	resourceGroupName := terraform.Output(t, beforeAllOptions, "resource_group_name")
	policyAssignmentName := terraform.Output(t, beforeAllOptions, "policy_assignment_name")

	for _, testCase := range testCases {
		location := testCase.configuration.(string)
		t.Run(location, func(t *testing.T) {
			testCase := testCase
			location := location
			t.Parallel()

			terraformDir := test_structure.CopyTerraformFolderToTemp(t, "..", "/test/location")
			tempRootFolderPath, _ := filepath.Abs(filepath.Join(terraformDir, "../../.."))
			defer os.RemoveAll(tempRootFolderPath)

			tfOptions := &terraform.Options{
				TerraformDir: terraformDir,
				Vars: map[string]interface{}{
					"location":            location,
					"resource_group_name": resourceGroupName,
				},
			}

			defer terraform.Destroy(t, tfOptions)
			_, err := terraform.InitAndApplyE(t, tfOptions)

			errorMessagesExpectedParts := []string{
				"Error Creating/Updating Virtual Network",
				"Error: Code=\"RequestDisallowedByPolicy\"",
				policyAssignmentName,
			}
			verifyPolicyTestCase(t, testCase, errorMessagesExpectedParts, err)
		})
	}
}
