package tester

// import (
// 	"fmt"
// 	"os"
// 	"path/filepath"
// 	"strings"
// 	"testing"

// 	"github.com/stretchr/testify/assert"

// 	tfFiles "github.com/gruntwork-io/terratest/modules/files"
// 	"github.com/gruntwork-io/terratest/modules/logger"
// 	"github.com/gruntwork-io/terratest/modules/terraform"
// )

// const tfOutputPolicyAssignmentName = "policy_assignment_name"

// type testRunner struct {
// 	tfExecPath string
// 	config     TestConfig
// }

// func newTestRunner(tfExecPath string, config TestConfig) *testRunner {
// 	return &testRunner{
// 		tfExecPath: tfExecPath,
// 		config:     config,
// 	}
// }

// func (runner *testRunner) Test(t *testing.T) {
// 	t.Parallel()

// 	beforeAllOptions := &terraform.Options{
// 		TerraformDir: filepath.Join(runner.config.TerraformDir, "setup"),
// 		Logger:       logger.Discard,
// 	}

// 	t.Cleanup(func() {
// 		terraform.Destroy(t, beforeAllOptions)
// 	})

// 	terraform.InitAndApply(t, beforeAllOptions)

// 	outputs := terraform.OutputAll(t, beforeAllOptions)

// 	errorMessagesExpectedParts := []string{
// 		runner.config.ErrorMessage,
// 		runner.config.ErrorCode,
// 		outputs[tfOutputPolicyAssignmentName].(string),
// 	}

// 	for _, c := range runner.config.Cases {
// 		testCase := c
// 		t.Run(fmt.Sprint(testCase.Variables), func(t *testing.T) {
// 			terraformDir, err := tfFiles.CopyTerraformFolderToTemp(runner.config.TerraformDir, "*")
// 			assert.Nil(t, err, "copy terraform to temp")

// 			defer os.RemoveAll(terraformDir)

// 			variables := make(map[string]interface{})

// 			for k, v := range outputs {
// 				if k != tfOutputPolicyAssignmentName {
// 					variables[k] = v
// 				}
// 			}

// 			for _, variable := range testCase.Variables {
// 				variables[variable.Key] = variable.Value
// 			}

// 			tfOptions := &terraform.Options{
// 				TerraformDir: terraformDir,
// 				Vars:         variables,
// 				Logger:       logger.Discard,
// 			}

// 			defer terraform.Destroy(t, tfOptions)
// 			_, err = terraform.InitAndApplyE(t, tfOptions)

// 			if err != nil {
// 				if testCase.ErrorExpected {
// 					matches := 0
// 					for _, part := range errorMessagesExpectedParts {
// 						if strings.Contains(err.Error(), part) {
// 							matches++
// 						}
// 					}
// 					assert.Equal(t, len(errorMessagesExpectedParts), matches, "deployment failed for an unexpected reason: %s", err)
// 				} else {
// 					t.Errorf("%s should be allowed values: %s", testCase.Variables, err)
// 				}
// 			} else if testCase.ErrorExpected {
// 				t.Errorf("%s should not be allowed values", testCase.Variables)
// 			}
// 		})
// 	}
// }
