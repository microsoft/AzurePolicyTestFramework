package tester

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"testing"

	"github.com/hashicorp/terraform-exec/tfinstall"
	"gopkg.in/yaml.v2"
)

func RunGoTest(configPath string) (int, error) {
	tmpDir, err := ioutil.TempDir("", "tfinstall")
	if err != nil {
		return 0, fmt.Errorf("create temp dir for TF installation: %w", err)
	}
	defer os.RemoveAll(tmpDir)

	tfExecPath, err := tfinstall.Find(context.Background(), tfinstall.LatestVersion(tmpDir, false))
	if err != nil {
		return 0, fmt.Errorf("locate Terraform binary: %w", err)
	}

	files, err := ioutil.ReadDir(configPath)

	if err != nil {
		return 0, fmt.Errorf("could not read directory path %s: %w", configPath, err)
	}

	runners := make([]*testRunner, 0)

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

			runners = append(runners, newTestRunner(tfExecPath, configPath, testConfig))
		}
	}

	tests := make([]testing.InternalTest, 0)
	for _, runner := range runners {
		tests = append(tests, testing.InternalTest{
			Name: runner.config.Name,
			F:    runner.Test,
		})
	}

	t := new(T)
	return testing.MainStart(t, tests, []testing.InternalBenchmark{}, []testing.InternalExample{}).Run(), nil
}
