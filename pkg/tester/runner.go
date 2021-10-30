package tester

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"path"
	"path/filepath"
	"strings"
	"testing"
	"time"

	tfFiles "github.com/gruntwork-io/terratest/modules/files"
	"github.com/hashicorp/terraform-exec/tfexec"
	"github.com/stretchr/testify/require"
)

const tfOutputPolicyAssignmentName = "policy_assignment_name"

type testRunner struct {
	tfExecPath string
	config     TestConfig
}

func newTestRunner(tfExecPath, configPath string, config TestConfig) *testRunner {
	runner := &testRunner{
		tfExecPath: tfExecPath,
		config:     config,
	}

	runner.config.TerraformDir = path.Join(configPath, runner.config.TerraformDir)

	return runner
}

func (runner *testRunner) Test(t *testing.T) {
	t.Parallel()
	ctx := context.Background()

	setup, err := tfexec.NewTerraform(filepath.Join(runner.config.TerraformDir, "setup"), runner.tfExecPath)
	require.NoError(t, err, "setup: failed to create a new Terraform object")

	require.NoErrorf(t, setup.Init(ctx, tfexec.Upgrade(false), tfexec.Reconfigure(true)), "setup: error running Init command. Directory: %s", setup.WorkingDir())

	t.Cleanup(func() {
		setup.Destroy(ctx)
	})

	require.NoError(t, setup.Apply(ctx, tfexec.Lock(false)), "setup: error running Apply command")

	outputs, err := setup.Output(ctx)
	require.NoError(t, err, "setup: error running Output command")

	var pan string
	require.NoErrorf(t, json.Unmarshal(outputs[tfOutputPolicyAssignmentName].Value, &pan), "setup: cannot unmarshall value of %s from the outputs", tfOutputPolicyAssignmentName)

	errorMessagesExpectedParts := []string{
		runner.config.ErrorMessage,
		runner.config.ErrorCode,
		pan,
	}

	vars := make([]tfexec.ApplyOption, 0)

	for key, output := range outputs {
		if key != tfOutputPolicyAssignmentName {
			var value string
			require.NoErrorf(t, json.Unmarshal(output.Value, &value), "setup: cannot unmarshall value of %s from the outputs", key)

			vars = append(vars, tfexec.Var(fmt.Sprintf("%s=%v", key, value)))
		}
	}

	time.Sleep(30 * time.Minute) // Time for the policy to be active

	for _, c := range runner.config.Cases {
		testCase := c

		t.Run(fmt.Sprint(testCase.Variables), func(t *testing.T) {
			t.Parallel()

			tmpDir, err := tfFiles.CopyTerraformFolderToTemp(runner.config.TerraformDir, "*")
			require.NoError(t, err, "create temp dir")

			t.Cleanup(func() {
				os.RemoveAll(tmpDir)
			})

			tf, err := tfexec.NewTerraform(tmpDir, runner.tfExecPath)
			require.NoError(t, err, "create a new Terraform object")

			require.NoError(t, tf.Init(ctx, tfexec.Upgrade(false)), "run Init command")

			t.Cleanup(func() {
				tf.Destroy(ctx)
			})

			applyOptions := make([]tfexec.ApplyOption, 0)
			applyOptions = append(applyOptions, vars...)

			for _, variable := range testCase.Variables {
				applyOptions = append(applyOptions, tfexec.Var(fmt.Sprintf("%s=%v", variable.Key, variable.Value)))
			}

			applyOptions = append(applyOptions, tfexec.Lock(false))

			err = tf.Apply(
				ctx,
				applyOptions...,
			)

			if err != nil {
				errString := err.Error()
				if testCase.ErrorExpected {
					matches := 0
					for _, part := range errorMessagesExpectedParts {
						if strings.Contains(errString, part) {
							matches++
						}
					}
					require.Equalf(t, len(errorMessagesExpectedParts), matches, "deployment failed for an unexpected reason: %s", errString)
				} else {
					require.FailNow(t, "deployment failed for an unexpected reason", errString)
				}
			} else if testCase.ErrorExpected {
				require.FailNowf(t, "values should be FORBIDDEN", "%s", testCase.Variables)
			}
		})
	}
}
