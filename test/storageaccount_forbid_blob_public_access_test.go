package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestStorageAccountForbidPublicBlobAccessPolicy(t *testing.T) {
	t.Parallel()

	testCases := []PolicyTestCase{
		{configuration: "true", errorExpected: true},
		{configuration: "false", errorExpected: false},
	}

	beforeAllOptions := &terraform.Options{
		TerraformDir: "./storageaccount-forbid-blob-public-access/beforeAll",
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
		blob_access := testCase.configuration.(string)
		t.Run(blob_access, func(t *testing.T) {
			testCase := testCase
			blob_access := blob_access
			t.Parallel()

			terraformDir := test_structure.CopyTerraformFolderToTemp(t, "..", "/test/storageaccount-forbid-blob-public-access")
			tempRootFolderPath, _ := filepath.Abs(filepath.Join(terraformDir, "../../.."))
			defer os.RemoveAll(tempRootFolderPath)

			tfOptions := &terraform.Options{
				TerraformDir: terraformDir,
				Vars: map[string]interface{}{
					"blob_access": blob_access,
					"resource_group_name": resourceGroupName,
				},
			}

			defer terraform.Destroy(t, tfOptions)
			_, err := terraform.InitAndApplyE(t, tfOptions)
			verifyPolicyTestCase(t, testCase, errorMessagesExpectedParts, err)
		})
	}
}
