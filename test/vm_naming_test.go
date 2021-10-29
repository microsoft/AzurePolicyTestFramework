package test

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestVirtualMachineNamingPolicy(t *testing.T) {
	t.Parallel()

	testCases := []PolicyTestCase{
		{configuration: "vm", errorExpected: true},
		{configuration: "abc", errorExpected: true},
		{configuration: "abc-", errorExpected: true},
		{configuration: "vvm-", errorExpected: true},
		{configuration: "vm-", errorExpected: false},
		{configuration: "VM-", errorExpected: false}, // Azure policy "like/notLike" operator is case insensitive
	}

	beforeAllOptions := &terraform.Options{
		TerraformDir: "./vm-naming/beforeAll",
	}

	t.Cleanup(func() {
		terraform.Destroy(t, beforeAllOptions)
	})
	terraform.InitAndApply(t, beforeAllOptions)
	resourceGroupName := terraform.Output(t, beforeAllOptions, "resource_group_name")
	policyAssignmentName := terraform.Output(t, beforeAllOptions, "policy_assignment_name")

	errorMessagesExpectedParts := []string{
		"creating Linux Virtual Machine",
		"Error: Code=\"RequestDisallowedByPolicy\"",
		policyAssignmentName,
	}

	for _, testCase := range testCases {
		t.Run(fmt.Sprintf("prefix=%s", testCase.configuration), func(t *testing.T) {
			testCase := testCase
			t.Parallel()

			terraformDir := test_structure.CopyTerraformFolderToTemp(t, "..", "/test/vm-naming")
			tempRootFolderPath, _ := filepath.Abs(filepath.Join(terraformDir, "../../.."))
			defer os.RemoveAll(tempRootFolderPath)

			tfOptions := &terraform.Options{
				TerraformDir: terraformDir,
				Vars: map[string]interface{}{
					"prefix":              testCase.configuration,
					"resource_group_name": resourceGroupName,
				},
			}

			defer terraform.Destroy(t, tfOptions)
			_, err := terraform.InitAndApplyE(t, tfOptions)

			verifyPolicyTestCase(t, testCase, errorMessagesExpectedParts, err)
		})
	}
}
