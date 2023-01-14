# JaCoCo Code Coverage Reporter

GitHub Action to Publish JaCoCo Format Code Coverage XML and attach it
to the Workflow Run as a Check Run. You can even set threshold coverage percentage and fail the action.

### Note:- 
* The scope of this project is limited to Report and Quality Gate. Any ideas are welcome. 
* I wrote this action as opensource during my vacation time.
* This actions is used by hundreds of repos in my organization and many other prviate org repos.

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
        uses: PavanMudigonda/jacoco-reporter@v4.8
        with:
          coverage_results_path: jacoco-report/test.xml
          coverage_report_name: Coverage
          coverage_report_title: JaCoCo
          github_token: ${{ secrets.GITHUB_TOKEN }}
          skip_check_run: false
          minimum_coverage: 80
          fail_below_threshold: false
          publish_only_summary: false
      
      # Publish Coverage Job Summary  # Optional
     - name: Add Coverage Job Summary
       run: echo "${{ steps.jacoco_reporter.outputs.coverageSummary }}" >> $GITHUB_STEP_SUMMARY
          
      # uploads the coverage-report.md artifact  # Optional

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
| **`coverage_percentage`** | Coverage Percentage. Rounded to two decimals.
| **`coveragePercentage`** | Coverage Percentage. Rounded to two decimals.
| **`coveragePercentageString`** | Coverage Percentage. Rounded to two decimals with % symbol attached.
| **`covered_lines`** | Total Covered Lines
| **`missed_lines`** | Total missed Lines
| **`total_lines`** | Total Code Lines
| **`coverageSummary`** | code coverage summary data mardown variable. Use this variable to append to $GITHUB_STEP_SUMMARY to publish summary.


### Important Notes:-

-   When action is run in a pull request by dependabot or a forked repo (e.g. when bumping up a version in a pull request) this step will fail with the default github token ${{ secrets.GITHUB_TOKEN }} due to a lack of permissions.
**Resolution:**  on consumer side of workflow please add below
1) 
**Possible fix**
The workflow needs `check: write` permissions.
```yaml
permissions:
  checks: write
```
2) Or Alternatively use Personal Authorization Token from GitHub.


### Sample Screenshot (Full Coverage Report): publish_only_summary: false

![image](https://user-images.githubusercontent.com/29324338/155446462-023a310a-c353-4a4c-9b3c-d25e7862ee74.png)


### Sample Screenshot (Summary Coverage Report): publish_only_summary: true

![image](https://user-images.githubusercontent.com/29324338/163588129-fbc94144-01b5-4af5-81ad-91a1e22a8c5d.png)

### Sample Build Summary Screenshot

<img width="1127" alt="image" src="https://user-images.githubusercontent.com/86745613/169406925-b1029ccb-ed62-4d6a-aa80-da81eca1601d.png">

### Sample PR Check Screenshot: only one Code Coverage Check Appears.

<img width="749" alt="image" src="https://user-images.githubusercontent.com/86745613/209163788-af98f77d-d80d-4986-8c09-e9f03ef86e15.png">

### Sample Gradle Build Repo 

https://github.com/PavanMudigonda/jacoco-playground

### Sample Gradle Github Actions workflow 

https://github.com/PavanMudigonda/jacoco-playground/blob/main/.github/workflows/coverage.yml

### Sample Maven Build Repo

https://github.com/PavanMudigonda/java-maven-playground/

### Sample Maven Github Actions workflow  

https://github.com/PavanMudigonda/java-maven-playground/blob/master/.github/workflows/ci.yml

### Sample Ant Build Repo


### Sample Ant Github Actions workflow  



### PowerShell GitHub Action

This Action is implemented as a [PowerShell GitHub Action](https://github.com/ebekker/pwsh-github-action-base).

### Please checkout my Lines of Code Reporter

https://github.com/PavanMudigonda/lines-of-code-reporter/
