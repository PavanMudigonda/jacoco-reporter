# JaCoCo Code Coverage Reporter

GitHub Action to Publish JaCoCo Format Code Coverage XML and attach it
to the Workflow Run as a Check Run.

## Samples


This Action allows you to specify your JaCoCo Code Coverage XML Path, and then
generate a markdown report from the test results and then it attaches it
to the Workflow Run as a Check Run.

Here's a quick example of how to use this action in your own GitHub Workflows.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: JaCoCo Code Coverage Report
        id: jacoco_reporter
        uses: PavanMudigonda/jacoco-reporter@v1.4
        with:
          coverage_results_path: jacoco-report/test.xml
          coverage_report_name: Code Coverage Report
          coverage_report_title: JaCoCo
          github_token: ${{ secrets.GITHUB_TOKEN }}
          skip_check_run: false
```


### Inputs

This Action defines the following formal inputs.

| Name | Req | Description
|-|-|-|
| **`coverage_results_path`**  | true | Path to the JaCoCo Code Coverage file which will be used to generate a report.  
| **`coverage_report_name`** | false | The name of the code coverage report object that will be attached to the Workflow Run.  Defaults to the name `COVERAGE_RESULTS_<datetime>` where `<datetime>` is in the form `yyyyMMdd_hhmmss`.
| **`coverage_report_title`** | false | The title of the code coverage report that will be embedded in the report itself, which defaults to the same as the `code_coverage_report_name` input.
|**`github_token`** | true | Input the GITHUB TOKEN Or Personal Access Token you would like to use.

### PowerShell GitHub Action

This Action is implemented as a [PowerShell GitHub Action](https://github.com/ebekker/pwsh-github-action-base).
