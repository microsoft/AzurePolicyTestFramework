# Azure Policy Test Framework

** Important note: this repository does not have CSS support **

This repository is a command line tool for testing Azure Policies.

## Usage

For each test case, the following directory structure must be created:

```txt
+-- your_test_name
|   +-- setup
|   |   +-- terraform files to setup the policy
|   +-- terraform files for test cases
```

Note: the definition of the policy and the content of the terraform test code is up to you. The folders `policy_defintions` and `test` aim to be used as examples.
You may define policies in Json (see `policy_defintions/location`), in TF (any other definition), in ARM template or whatever suits your need as long as you are able to wrap it in Terraform.

Additionally, a `.yaml` configuration file must describe the test as following:

```yaml
name: Name of the test
cases:
- variables:
  - key: variable name in TF
    value: val
  errorExpected: true
- variables:
  - key: variable name in TF
    value: val2
  errorExpected: false
terraformDir: relative path to the folder structure described above
errorMessage: Error message from Azure (ex 'Error creating Network Interface')
errorCode: Error code from Azure (ex 'Error Code=\"RequestDisallowedByPolicy\"')
```

To run from the source code:

```bash
go run ./cmd/policyTester/ -config ./test/ -test.v
```

Note: any args from the `go test` command are available for use. For instance:

```bash
go run ./cmd/policyTester/ -config ./test/ -test.v -test.parallel=10 -test.run Location
```

## About Azure Policies

Azure Policy helps to enforce organizational standards and to assess compliance at-scale. Through its compliance dashboard, it provides an aggregated view to evaluate the overall state of the environment, with the ability to drill down to the per-resource, per-policy granularity. It also helps to bring your resources to compliance through bulk remediation for existing resources and automatic remediation for new resources.

Here are some resources about Azure Policies:

- [Policy Structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure)
- [Policy Effects](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects)
- [Policy Aliases](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#aliases)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Microsoft Contributor License Agreement](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
