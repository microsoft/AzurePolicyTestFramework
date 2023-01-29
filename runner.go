package tester

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

type testRunner struct {
	testCase PolicyTestCase
}

func newTestRunner(testCase PolicyTestCase) *testRunner {
	runner := &testRunner{
		testCase: testCase,
	}

	return runner
}

func TerraformApply(t *testing.T, stage *Config) (*terraform.Options, error) {
	tmpDir := test_structure.CopyTerraformFolderToTemp(t, stage.Path, "./")
	opts := &terraform.Options{
		TerraformDir: tmpDir,
		Reconfigure:  true,
		Vars:         stage.Variables,
		VarFiles:     stage.VarFiles,
	}
	_, err := terraform.InitAndApplyE(t, opts)
	if stage.ErrorMessage != nil {
		if err != nil && strings.Contains(err.Error(), *stage.ErrorMessage) {
			return opts, nil
		}
		return opts, fmt.Errorf("expected '%v', got:'%v'", stage.ErrorMessage, err)
	}
	return opts, err
}
func runNext(t *testing.T, in map[string]interface{}, stage *Config) (map[string]interface{}, *terraform.Options, error) {
	stage.Variables = merge(in, stage.Variables)
	testOpts, err := TerraformApply(t, stage)
	if err != nil {
		return nil, testOpts, err
	}
	testOutput, err := terraform.OutputAllE(t, testOpts)
	return testOutput, testOpts, err
}

func (runner *testRunner) Test(t *testing.T) {
	t.Parallel()
	if runner.testCase.Setup == nil {
		t.Fatal("setup configuration is mandatory")
	}
	setupOutput, setupOpts, err := runNext(t, nil, runner.testCase.Setup)
	defer terraform.Destroy(t, setupOpts)
	require.Nil(t, err)
	if runner.testCase.Test != nil {
		testOutput, testOpts, err := runNext(t, setupOutput, runner.testCase.Test)
		defer terraform.Destroy(t, testOpts)
		require.Nil(t, err)
		if runner.testCase.AfterTest != nil {
			_, afterOpts, err := runNext(t, testOutput, runner.testCase.AfterTest)
			defer terraform.Destroy(t, afterOpts)
			require.Nil(t, err)
		}
	}
}

func merge(in map[string]interface{}, out map[string]interface{}) map[string]interface{} {
	if in != nil {
		for k, v := range in {
			out[k] = v
		}
	}
	return out
}
