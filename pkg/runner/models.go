package runner

type TestConfig struct {
	Cases []PolicyTestCase `yaml:"cases"`
}

type Config struct {
	Path              string                 `yaml:"path"`
	ErrorMessage      *string                `yaml:"errorMessage"`
	WaitBeforeRunning *string                `yaml:"waitBeforeRunning"`
	ErrorCode         *string                `yaml:"errorCode"`
	Variables         map[string]interface{} `yaml:"variables"`
	VarFiles          []string               `yaml:"varFiles"`
}
type PolicyTestCase struct {
	Name  string  `yaml:"name"`
	Setup *Config `yaml:"setup"`
	Test  *Config `yaml:"test"`
	After *Config `yaml:"after"`
}
