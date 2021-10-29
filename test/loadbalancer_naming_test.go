package test

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestInternalLoadBalancerNamingConventionPolicy(t *testing.T) {
	t.Parallel()

	testCases := []PolicyTestCase{
		{configuration: "ilb-", errorExpected: true},
		{configuration: "lb", errorExpected: true},
		{configuration: "plb-", errorExpected: true},
		{configuration: "ilb", errorExpected: true},
		{configuration: "lb-", errorExpected: false},
	}

	beforeAllOptions := &terraform.Options{
		TerraformDir: "./loadbalancer-naming/beforeAll",
	}

	t.Cleanup(func() {
		terraform.Destroy(t, beforeAllOptions)
	})
	terraform.InitAndApply(t, beforeAllOptions)
	resourceGroupName := terraform.Output(t, beforeAllOptions, "resource_group_name")
	policyAssignmentName := terraform.Output(t, beforeAllOptions, "policy_assignment_name")
	subnetId := terraform.Output(t, beforeAllOptions, "subnet_id")

	errorMessagesExpectedParts := []string{
		"Error Creating/Updating Load Balancer",
		"Code=\"RequestDisallowedByPolicy\"",
		policyAssignmentName,
	}

	for _, testCase := range testCases {
		prefix := testCase.configuration.(string)
		t.Run(fmt.Sprintf("prefix=%s", testCase.configuration), func(t *testing.T) {
			testCase := testCase
			t.Parallel()

			terraformDir := test_structure.CopyTerraformFolderToTemp(t, "..", "/test/loadbalancer-naming")
			tempRootFolderPath, _ := filepath.Abs(filepath.Join(terraformDir, "../../.."))
			defer os.RemoveAll(tempRootFolderPath)

			tfOptions := &terraform.Options{
				TerraformDir: terraformDir,
				Vars: map[string]interface{}{
					"prefix":              prefix,
					"resource_group_name": resourceGroupName,
					"subnet_id":           subnetId,
				},
			}

			defer terraform.Destroy(t, tfOptions)
			_, err := terraform.InitAndApplyE(t, tfOptions)

			verifyPolicyTestCase(t, testCase, errorMessagesExpectedParts, err)
		})
	}
}
