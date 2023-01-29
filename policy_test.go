package tester

import (
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
	"sigs.k8s.io/yaml"
)

const configPath = "test"

func TestPolicies(t *testing.T) {
	files, err := ioutil.ReadDir(configPath)
	require.Nil(t, err)
	for _, file := range files {
		if filepath.Ext(file.Name()) == ".yaml" {
			yamlFile, err := os.Open(filepath.Join(configPath, file.Name()))
			if err != nil {
				continue
			}

			defer yamlFile.Close()

			byteValue, _ := ioutil.ReadAll(yamlFile)

			var testConfig TestConfig
			if err := yaml.Unmarshal(byteValue, &testConfig); err != nil {
				log.Printf("Could not unmarshal file %s: %v", file.Name(), err)
				continue
			}
			for _, tc := range testConfig.Cases {
				testRunner := newTestRunner(tc)
				t.Run(testRunner.testCase.Name, testRunner.Test)
			}
		}
	}
}
