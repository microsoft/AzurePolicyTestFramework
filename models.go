package tester

type TestConfig struct {
	Cases []PolicyTestCase `yaml:"cases"`
}

type Config struct {
	Path         string                 `yaml:"path"`
	ErrorMessage *string                `yaml:"errorMessage"`
	ErrorCode    *string                `yaml:"errorCode"`
	Variables    map[string]interface{} `yaml:"variables"`
	VarFiles     []string               `yaml:"varFiles"`
}
type PolicyTestCase struct {
	Name      string  `yaml:"name"`
	Setup     *Config `yaml:"setup"`
	Test      *Config `yaml:"test"`
	AfterTest *Config `yaml:"after"`
}
