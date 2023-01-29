package runner

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

type testRunner struct {
	TestCase PolicyTestCase
}

func NewTestRunner(testCase PolicyTestCase) *testRunner {
	runner := &testRunner{
		TestCase: testCase,
	}
	return runner
}

func TerraformApply(t *testing.T, stage *Config) (*terraform.Options, error) {
	tmpDir := test_structure.CopyTerraformFolderToTemp(t, "./", stage.Path)
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
	if stage == nil {
		return nil, nil, nil
	}
	if stage.WaitBeforeRunning != nil {
		logger.Default.Logf(t, "waiting '%s' before running", *stage.WaitBeforeRunning)
		dur, err := time.ParseDuration(*stage.WaitBeforeRunning)
		if err != nil {
			return nil, nil, err
		}
		time.Sleep(dur)
	}
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
	if runner.TestCase.Setup == nil {
		t.Fatal("setup configuration is mandatory")
	}
	setupOutput, setupOpts, err := runNext(t, nil, runner.TestCase.Setup)
	if setupOpts != nil {
		defer terraform.Destroy(t, setupOpts)
	}
	require.Nil(t, err)
	testOutput, testOpts, err := runNext(t, setupOutput, runner.TestCase.Test)
	if testOpts != nil {
		defer terraform.Destroy(t, testOpts)
	}
	require.Nil(t, err)
	_, afterOpts, err := runNext(t, testOutput, runner.TestCase.After)
	if afterOpts != nil {
		defer terraform.Destroy(t, afterOpts)
	}
	require.Nil(t, err)
}

func merge(in map[string]interface{}, out map[string]interface{}) map[string]interface{} {
	if out == nil {
		return in
	}
	if in != nil {
		for k, v := range in {
			out[k] = v
		}
	}
	return out
}
