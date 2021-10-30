package tester

import "io"

type T struct{}

func (t *T) MatchString(pat, str string) (bool, error) {
	return true, nil
}

func (t *T) StartCPUProfile(io.Writer) error {
	return nil
}

func (t *T) StopCPUProfile() {}

func (t *T) WriteHeapProfile(io.Writer) error {
	return nil
}

func (t *T) WriteProfileTo(string, io.Writer, int) error {
	return nil
}

func (t *T) ImportPath() string {
	return ""
}

func (t *T) SetPanicOnExit0(bool) {}

func (t *T) StartTestLog(io.Writer) {}

func (t *T) StopTestLog() error {
	return nil
}
