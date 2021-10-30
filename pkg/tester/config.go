package tester

type TestConfig struct {
	Name         string           `yaml:"name"`
	Cases        []PolicyTestCase `yaml:"cases"`
	TerraformDir string           `yaml:"terraformDir"`
	ErrorMessage string           `yaml:"errorMessage"`
	ErrorCode    string           `yaml:"errorCode"`
}

type PolicyTestCase struct {
	ErrorExpected bool               `yaml:"wantErr"`
	Variables     []TestCaseVariable `yaml:"variables"`
}

type TestCaseVariable struct {
	Key   string      `yaml:"key"`
	Value interface{} `yaml:"value"`
}
