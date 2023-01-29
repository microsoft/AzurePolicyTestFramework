package tester

import (
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"testing"

	"github.com/ContainerSolutions/AzurePolicyTestFramework/pkg/runner"
	"github.com/stretchr/testify/require"
	"sigs.k8s.io/yaml"
)

func TestPolicies(t *testing.T) {
	configPath := os.Getenv("TEST_CONFIG_PATH")
	if configPath == "" {
		configPath = "./"
	}
	testPattern := os.Getenv("TEST_PATTERN")
	if testPattern == "" {
		testPattern = ".*"
	}
	re := regexp.MustCompile(testPattern)
	walkFn := func(path string, info fs.FileInfo, err error) error {
		if filepath.Ext(path) == ".yaml" {
			yamlFile, err := os.Open(path)
			if err != nil {
				return err
			}

			defer yamlFile.Close()

			byteValue, _ := io.ReadAll(yamlFile)

			var testConfig runner.TestConfig
			if err := yaml.Unmarshal(byteValue, &testConfig); err != nil {
				return fmt.Errorf("Could not unmarshal file %s: %w", path, err)
			}
			for _, tc := range testConfig.Cases {
				testRunner := runner.NewTestRunner(tc)
				if re.Match([]byte(testRunner.TestCase.Name)) {
					t.Run(testRunner.TestCase.Name, testRunner.Test)
				}
			}
		}
		return nil
	}
	err := filepath.Walk(configPath, walkFn)
	require.Nil(t, err)
}
