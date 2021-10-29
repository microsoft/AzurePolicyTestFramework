package test

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestResourceGroupNamingConventionPolicy(t *testing.T) {
	t.Parallel()

	testCases := []PolicyTestCase{
		{configuration: "gr-", errorExpected: true},
		{configuration: "gr", errorExpected: true},
		{configuration: "rg", errorExpected: true},
		{configuration: "rg-", errorExpected: false},
	}

	beforeAllOptions := &terraform.Options{
		TerraformDir: "./resourcegroup-naming/beforeAll",
	}

	t.Cleanup(func() {
		terraform.Destroy(t, beforeAllOptions)
	})
	terraform.InitAndApply(t, beforeAllOptions)
	policyAssignmentName := terraform.Output(t, beforeAllOptions, "policy_assignment_name")

	errorMessagesExpectedParts := []string{
		"Error creating Resource Group",
		"Code=\"RequestDisallowedByPolicy\"",
		policyAssignmentName,
	}

	for _, testCase := range testCases {
		prefix := testCase.configuration.(string)
		t.Run(fmt.Sprintf("prefix=%s", testCase.configuration), func(t *testing.T) {
			testCase := testCase
			t.Parallel()

			terraformDir := test_structure.CopyTerraformFolderToTemp(t, "..", "/test/resourcegroup-naming")
			tempRootFolderPath, _ := filepath.Abs(filepath.Join(terraformDir, "../../.."))
			defer os.RemoveAll(tempRootFolderPath)

			tfOptions := &terraform.Options{
				TerraformDir: terraformDir,
				Vars: map[string]interface{}{
					"prefix": prefix,
				},
			}

			defer terraform.Destroy(t, tfOptions)
			_, err := terraform.InitAndApplyE(t, tfOptions)

			verifyPolicyTestCase(t, testCase, errorMessagesExpectedParts, err)
		})
	}
}
