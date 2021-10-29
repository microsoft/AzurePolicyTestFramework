package test

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestDenyWindowsVM(t *testing.T) {
	t.Parallel()

	testCases := []PolicyTestCase{
		{
			configuration: map[string]string{"publisher": "MicrosoftWindowsServer", "offer": "WindowsServer", "sku": "2019-Datacenter", "version": "latest"},
			errorExpected: true,
		},
		{
			configuration: map[string]string{"publisher": "MicrosoftWindowsServer", "offer": "WindowsServer", "sku": "2016-Datacenter", "version": "latest"},
			errorExpected: true,
		},
		{
			configuration: map[string]string{"publisher": "MicrosoftWindowsServer", "offer": "WindowsServer", "sku": "2012-Datacenter", "version": "latest"},
			errorExpected: true,
		},
		{
			configuration: map[string]string{"publisher": "MicrosoftWindowsDesktop", "offer": "Windows-7", "sku": "win7-enterprise", "version": "latest"},
			errorExpected: true,
		},
		{
			configuration: map[string]string{"publisher": "MicrosoftWindowsDesktop", "offer": "Windows-10", "sku": "20h2-pro", "version": "latest"},
			errorExpected: true,
		},
		{
			configuration: map[string]string{"publisher": "MicrosoftWindowsDesktop", "offer": "Windows-10", "sku": "rs1-enterprise", "version": "latest"},
			errorExpected: true,
		},
		{
			configuration: map[string]string{"publisher": "OpenLogic", "offer": "CentOS", "sku": "8_2", "version": "latest"},
			errorExpected: false,
		},
	}

	beforeAllOptions := &terraform.Options{
		TerraformDir: "./windows-vm/beforeAll",
	}

	t.Cleanup(func() {
		terraform.Destroy(t, beforeAllOptions)
	})
	terraform.InitAndApply(t, beforeAllOptions)
	resourceGroupName := terraform.Output(t, beforeAllOptions, "resource_group_name")

	for _, testCase := range testCases {
		for _, useScaleSet := range []bool{true, false} {
			configuration := testCase.configuration.(map[string]string)
			subTestName := fmt.Sprintf("%s-%s-vmss-%v", configuration["offer"], configuration["sku"], useScaleSet)
			t.Run(subTestName, func(t *testing.T) {
				testCase := testCase
				useScaleSet := useScaleSet
				t.Parallel()

				terraformDir := test_structure.CopyTerraformFolderToTemp(t, "..", "/test/windows-vm")
				tempRootFolderPath, _ := filepath.Abs(filepath.Join(terraformDir, "../../.."))
				defer os.RemoveAll(tempRootFolderPath)

				tfOptions := &terraform.Options{
					TerraformDir: terraformDir,
					Vars: map[string]interface{}{
						"resource_group_name":    resourceGroupName,
						"source_image_reference": testCase.configuration,
						"use_scale_set":          useScaleSet,
					},
				}

				defer terraform.Destroy(t, tfOptions)
				_, err := terraform.InitAndApplyE(t, tfOptions)

				expectedErrorMessageParts := []string{
					"creating Windows Virtual Machine",
					"Error: Code=\"RequestDisallowedByPolicy\"",
					"ci-deny-windows-vm-policy-assignment",
				}
				verifyPolicyTestCase(t, testCase, expectedErrorMessageParts, err)
			})
		}
	}
}
