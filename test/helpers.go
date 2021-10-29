package test

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

type PolicyTestCase struct {
	name          string
	errorExpected bool
	configuration interface{}
}

func verifyPolicyTestCase(t *testing.T, testCase PolicyTestCase, errorMessagePartsExpected []string, err error) {
	if err != nil && testCase.errorExpected {
		assert.Condition(t, func() (success bool) {
			matches := 0
			for _, part := range errorMessagePartsExpected {
				if strings.Contains(err.Error(), part) {
					matches++
				}
			}

			return len(errorMessagePartsExpected) == matches
		}, "Deployment failed for another reason than the one expected")
	} else if testCase.errorExpected {
		assert.NotNilf(t, err, "%v should not be an allowed value", testCase.configuration)
	} else if testCase.errorExpected == false {
		assert.Nilf(t, err, "%v should be an allowed value", testCase.configuration)
	}
}
