package tester

import (
	"io"
	"regexp"
)

type T struct{}

func (t *T) MatchString(pat, str string) (bool, error) {
	matchRe, err := regexp.Compile(pat)
	if err != nil {
		return false, err
	}
	return matchRe.MatchString(str), nil
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
