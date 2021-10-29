package test

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestVirtualNetworkNamingConventionPolicy(t *testing.T) {
	t.Parallel()

	testCases := []PolicyTestCase{
		{configuration: "vnet", errorExpected: true},
		{configuration: "abc", errorExpected: true},
		{configuration: "abc-", errorExpected: true},
		{configuration: "vnet-", errorExpected: false},
	}

	beforeAllOptions := &terraform.Options{
		TerraformDir: "./vnet-naming/beforeAll",
	}

	t.Cleanup(func() {
		terraform.Destroy(t, beforeAllOptions)
	})
	terraform.InitAndApply(t, beforeAllOptions)
	resourceGroupName := terraform.Output(t, beforeAllOptions, "resource_group_name")
	policyAssignmentName := terraform.Output(t, beforeAllOptions, "policy_assignment_name")

	for _, testCase := range testCases {
		prefix := testCase.configuration.(string)
		t.Run(fmt.Sprintf("prefix=%s", prefix), func(t *testing.T) {
			testCase := testCase
			prefix := prefix
			t.Parallel()

			terraformDir := test_structure.CopyTerraformFolderToTemp(t, "..", "/test/vnet-naming")
			tempRootFolderPath, _ := filepath.Abs(filepath.Join(terraformDir, "../../.."))
			defer os.RemoveAll(tempRootFolderPath)

			tfOptions := &terraform.Options{
				TerraformDir: terraformDir,
				Vars: map[string]interface{}{
					"prefix":              prefix,
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
