# JaCoCo Code Coverage Reporter

GitHub Action to Publish JaCoCo Format Code Coverage XML and attach it
to the Workflow Run as a Check Run. You can even set threshold coverage percentage and fail the action.

### Note:- The scope of this project is limited to Report and Quality Gate. Any ideas are welcome. 
###        If you like my Github Action, please **STAR ⭐** it.

## Samples


This Action allows you to specify your JaCoCo Code Coverage XML Path, and then
generate a markdown report from the test results and then it attaches it
to the Workflow Run as a Check Run. You can even set threshold coverage percentage and fail the action.

Here's a quick example of how to use this action in your own GitHub Workflows.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    
      # generates coverage-report.md and publishes as checkrun
      - name: JaCoCo Code Coverage Report
        id: jacoco_reporter
        uses: PavanMudigonda/jacoco-reporter@v4.3
        with:
          coverage_results_path: jacoco-report/test.xml
          coverage_report_name: Coverage
          coverage_report_title: JaCoCo
          github_token: ${{ secrets.GITHUB_TOKEN }}
          skip_check_run: false
          minimum_coverage: 80
          fail_below_threshold: false
          publish_only_summary: false

    # Publish Job Summary (optional). #Temporary solution. will output markdown in to variable in few days in a new release !
    - name: construct coverage job summary markdown
      run: |
        cat > coverage_summary.md <<EOF
          | Code Coverage Summary            | Value                                                      |
          |----------------------------------|------------------------------------------------------------|
          | Code Coverage %                  | ${{ steps.jacoco_reporter.outputs.coverage_percentage }} % |
          | :heavy_check_mark: Lines Covered | ${{ steps.jacoco_reporter.outputs.covered_lines }}         |
          | :x: Lines Missed                 | ${{ steps.jacoco_reporter.outputs.missed_lines }}          |
          | Total Lines                      | ${{ steps.jacoco_reporter.outputs.total_lines }}           |
        EOF
        cat coverage_summary.md >> $GITHUB_STEP_SUMMARY
        
      # uploads the coverage-report.md artifact (optional)
      - name: Upload Code Coverage Artifacts
        uses: actions/upload-artifact@v2
        with:
          name: code-coverage-report-markdown
          path: */coverage-results.md 
          retention-days: 1  
```


### Inputs

This Action defines the following formal inputs.

| Name | Req | Description
|-|-|-|
| **`coverage_results_path`**  | true | Path to the JaCoCo Code Coverage XML format file which will be used to generate a report. 
| **`coverage_report_name`** | false | The name of the code coverage report object that will be attached to the Workflow Run.  Defaults to the name `COVERAGE_RESULTS_<datetime>` where `<datetime>` is in the form `yyyyMMdd_hhmmss`.
| **`coverage_report_title`** | false | The title of the code coverage report that will be embedded in the report itself, which defaults to the same as the `coverage_report_name` input.
|**`github_token`** | true | Input the GITHUB TOKEN Or Personal Access Token you would like to use. Recommended to use GitHub auto generated token ${{ secrets.GITHUB_TOKEN }}
|**`minimum_coverage`** | false | Input the minimum code coverage recommended.
|**`fail_below_threshold`** | false | Set True to fail the action and False to let it pass.
|**`skip_check_run`** | false | If true, will skip attaching the Coverage Result report to the Workflow Run using a Check Run. Useful if your report has 65k characters that is not accepted by Github REST and GraphQL APIs
|**`publish_only_summary`** | false | If true, will publish only a summary table of the Coverage Result report to the Workflow Run using a Check Run. Useful if your full coverage report has 65k characters that is not accepted by Github REST and GraphQL APIs

### Outputs

This Action defines the following formal outputs.

| Name | Description
|-|-|
| **`coverage_percentage`** | Coverage Percentage
| **`covered_lines`** | Total Covered Lines
| **`missed_lines`** | Total missed Lines
| **`total_lines`** | Total Code Lines
| **`coverage_results_path`** | Path to the code coverage results file in XML format.

### Sample Screenshot (Full Coverage Report): publish_only_summary: false

![image](https://user-images.githubusercontent.com/29324338/155446462-023a310a-c353-4a4c-9b3c-d25e7862ee74.png)


### Sample Screenshot (Summary Coverage Report): publish_only_summary: true

![image](https://user-images.githubusercontent.com/29324338/163588129-fbc94144-01b5-4af5-81ad-91a1e22a8c5d.png)

## Sample Summary Screenshot

<img width="1127" alt="image" src="https://user-images.githubusercontent.com/86745613/169406925-b1029ccb-ed62-4d6a-aa80-da81eca1601d.png">


### Sample Repo 

https://github.com/PavanMudigonda/jacoco-playground

### Sample Github Actions workflow 

https://github.com/PavanMudigonda/jacoco-playground/blob/main/.github/workflows/coverage.yml


### PowerShell GitHub Action

This Action is implemented as a [PowerShell GitHub Action](https://github.com/ebekker/pwsh-github-action-base).
