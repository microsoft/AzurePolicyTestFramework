package main

import (
	"flag"
	"log"
	"os"
	"testing"

	"github.com/microsoft/AzurePolicyTestFramework/pkg/tester"
)

var (
	cases *string
)

func init() {
	cases = flag.String("config", "", "path to the test cases")
}

func main() {
	testing.Init()
	flag.Parse()

	code, err := tester.RunGoTest(*cases)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(code)
}
