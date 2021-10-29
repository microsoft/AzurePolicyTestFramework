package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestStorageAccountMinimumTLS12Policy(t *testing.T) {
	t.Parallel()

	testCases := []PolicyTestCase{
		{configuration: "TLS1_0", errorExpected: true},
		{configuration: "TLS1_1", errorExpected: true},
		{configuration: "TLS1_2", errorExpected: false},
	}

	beforeAllOptions := &terraform.Options{
		TerraformDir: "./storageaccount-minimum-tls1-2/beforeAll",
	}

	t.Cleanup(func() {
		terraform.Destroy(t, beforeAllOptions)
	})
	terraform.InitAndApply(t, beforeAllOptions)
	resourceGroupName := terraform.Output(t, beforeAllOptions, "resource_group_name")
	policyAssignmentName := terraform.Output(t, beforeAllOptions, "policy_assignment_name")

	errorMessagesExpectedParts := []string{
		"Error creating Azure Storage Account",
		"Error: Code=\"RequestDisallowedByPolicy\"",
		policyAssignmentName,
	}

	for _, testCase := range testCases {
		tls_version := testCase.configuration.(string)
		t.Run(tls_version, func(t *testing.T) {
			testCase := testCase
			tls_version := tls_version
			t.Parallel()

			terraformDir := test_structure.CopyTerraformFolderToTemp(t, "..", "/test/storageaccount-minimum-tls1-2")
			tempRootFolderPath, _ := filepath.Abs(filepath.Join(terraformDir, "../../.."))
			defer os.RemoveAll(tempRootFolderPath)

			tfOptions := &terraform.Options{
				TerraformDir: terraformDir,
				Vars: map[string]interface{}{
					"tls_version": tls_version,
					"resource_group_name": resourceGroupName,
				},
			}

			defer terraform.Destroy(t, tfOptions)
			_, err := terraform.InitAndApplyE(t, tfOptions)
			verifyPolicyTestCase(t, testCase, errorMessagesExpectedParts, err)
		})
	}
}
