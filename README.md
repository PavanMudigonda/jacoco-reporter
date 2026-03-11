# JaCoCo Code Coverage Reporter

GitHub Action that publishes JaCoCo XML coverage reports as GitHub Check Runs and
enforces a Code Coverage Quality Gate.

> If you find this action useful, please **STAR ⭐** the repo — it helps a lot!

---

## Quick Start

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    permissions:
      checks: write   # required to create/update Check Runs

    steps:
      - uses: actions/checkout@v4

      # Run your build and generate jacoco.xml here...

      - name: JaCoCo Coverage Report
        id: jacoco
        uses: PavanMudigonda/jacoco-reporter@v5.2
        with:
          coverage_results_path: build/reports/jacoco/test/jacocoTestReport.xml
          coverage_report_name: Coverage
          coverage_report_title: JaCoCo
          github_token: ${{ secrets.GITHUB_TOKEN }}
          minimum_coverage: 80
          fail_below_threshold: true

      # Add coverage table to the GitHub Job Summary
      - name: Add Coverage to Job Summary
        run: echo "${{ steps.jacoco.outputs.coverageSummary }}" >> $GITHUB_STEP_SUMMARY

      # Upload the markdown report as a workflow artifact (optional)
      - name: Upload Coverage Report
        uses: actions/upload-artifact@v4
        with:
          name: code-coverage-report-markdown
          path: '**/coverage-results.md'
          retention-days: 1
```

---

## Inputs

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `coverage_results_path` | ✅ | — | Path to one or more JaCoCo XML files. Accepts a **comma-separated list** for multi-module projects: `module-a/jacoco.xml, module-b/jacoco.xml`. Coverage % is based on **LINE** counters — this will differ from JaCoCo HTML reports, which show INSTRUCTION coverage. |
| `github_token` | | `${{ github.token }}` | Token used to authenticate against the GitHub API. |
| `ghes_api_endpoint` | | — | GitHub Enterprise Server API URL (e.g. `https://github.example.com/api/v3`). When set, all API calls are directed here instead of `https://api.github.com`. |
| `coverage_report_name` | | `COVERAGE_RESULTS_<datetime>` | Name of the Check Run attached to the Workflow Run. |
| `coverage_report_title` | | same as `coverage_report_name` | Title embedded inside the report. |
| `minimum_coverage` | | — | Minimum required coverage percentage (integer). Used with `fail_below_threshold`. |
| `fail_below_threshold` | | `false` | When `true`, the action fails if coverage is below `minimum_coverage`. |
| `skip_check_run` | | `false` | When `true`, skips publishing the Check Run. Use when you only want the Job Summary output. |
| `publish_only_summary` | | `false` | When `true`, publishes only the summary table instead of the full file-level report. The action also switches to summary automatically when the full report exceeds the 65k-character GitHub API limit. |

---

## Outputs

| Name | Description |
|------|-------------|
| `coverage_percentage` | Coverage percentage as a number (e.g. `85.23`). Based on LINE coverage. |
| `coveragePercentage` | Alias for `coverage_percentage`. |
| `coveragePercentageString` | Coverage percentage as a formatted string (e.g. `85.23 %`). |
| `covered_lines` | Number of lines covered by tests. |
| `missed_lines` | Number of lines not covered by tests. |
| `total_lines` | Total number of instrumented lines. |
| `coverageSummary` | Full markdown content of the generated report. Useful for Job Summary steps or PR comments. |

---

## Usage Examples

### Publish summary to Job Summary only (skip Check Run)

```yaml
- name: JaCoCo Coverage Report
  id: jacoco
  uses: PavanMudigonda/jacoco-reporter@v5.2
  with:
    coverage_results_path: build/reports/jacoco/test/jacocoTestReport.xml
    coverage_report_name: Coverage
    github_token: ${{ secrets.GITHUB_TOKEN }}
    skip_check_run: true

- name: Add Coverage to Job Summary
  run: echo "${{ steps.jacoco.outputs.coverageSummary }}" >> $GITHUB_STEP_SUMMARY
```

### Multi-module projects

```yaml
- name: JaCoCo Coverage Report
  uses: PavanMudigonda/jacoco-reporter@v5.2
  with:
    coverage_results_path: >-
      module-core/build/reports/jacoco/jacocoTestReport.xml,
      module-api/build/reports/jacoco/jacocoTestReport.xml,
      module-web/build/reports/jacoco/jacocoTestReport.xml
    coverage_report_name: Coverage
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

Line counts are summed across all modules and a combined report is produced.

### GitHub Enterprise Server (GHES)

```yaml
- name: JaCoCo Coverage Report
  uses: PavanMudigonda/jacoco-reporter@v5.2
  with:
    coverage_results_path: build/reports/jacoco/test/jacocoTestReport.xml
    coverage_report_name: Coverage
    github_token: ${{ secrets.GITHUB_TOKEN }}
    ghes_api_endpoint: https://github.example.com/api/v3
```

### Use coverage percentage in downstream steps

```yaml
- name: JaCoCo Coverage Report
  id: jacoco
  uses: PavanMudigonda/jacoco-reporter@v5.2
  with:
    coverage_results_path: build/reports/jacoco/test/jacocoTestReport.xml
    github_token: ${{ secrets.GITHUB_TOKEN }}

- name: Fail if coverage drops below 80%
  if: ${{ steps.jacoco.outputs.coverage_percentage < 80 }}
  run: echo "Coverage dropped below 80%!" && exit 1
```

---

## Permissions

The workflow job needs `checks: write` permission to create or update Check Runs:

```yaml
jobs:
  test:
    permissions:
      checks: write
```

Without this, the action fails with a 403 when run on pull requests from forks or
Dependabot PRs. Alternatively, supply a Personal Access Token via `github_token`.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Two Check Runs appear on the same PR | Workflow triggers on both `push` and `pull_request` simultaneously | The action automatically updates an existing Check Run instead of creating a duplicate |
| `embedmissedlines.ps1` fails with "parameter 'Path' is null" | A class's package path doesn't match its directory structure | The action now emits a warning and skips the embed instead of failing |
| Report truncated / API silent hang | Full report exceeds GitHub's 65k-character limit | The action automatically falls back to summary mode and logs a warning |
| `pwsh` not found on self-hosted runner | PowerShell not installed | The action auto-installs PowerShell via `snap` or `apt-get` on Linux, `brew` on macOS |
| Coverage % differs from JaCoCo HTML | HTML shows INSTRUCTION coverage; this action uses LINE coverage | Expected — set `minimum_coverage` based on LINE coverage values |

---

## Sample Screenshots

**Full report** (`publish_only_summary: false`)

![Full report](https://user-images.githubusercontent.com/29324338/155446462-023a310a-c353-4a4c-9b3c-d25e7862ee74.png)

**Summary report** (`publish_only_summary: true`)

![Summary report](https://user-images.githubusercontent.com/29324338/163588129-fbc94144-01b5-4af5-81ad-91a1e22a8c5d.png)

**Job Summary**

<img width="1127" alt="Job summary" src="https://user-images.githubusercontent.com/86745613/169406925-b1029ccb-ed62-4d6a-aa80-da81eca1601d.png">

---

## Sample Repositories

| Build Tool | Repo | Workflow |
|------------|------|----------|
| Gradle | [jacoco-playground](https://github.com/PavanMudigonda/jacoco-playground) | [coverage.yml](https://github.com/PavanMudigonda/jacoco-playground/blob/main/.github/workflows/coverage.yml) |
| Maven | [java-maven-playground](https://github.com/PavanMudigonda/java-maven-playground/) | [ci.yml](https://github.com/PavanMudigonda/java-maven-playground/blob/master/.github/workflows/ci.yml) |

---

## Related Actions

- [Lines of Code Reporter](https://github.com/PavanMudigonda/lines-of-code-reporter/)
- [GitHub Pages HTML Reporter](https://github.com/PavanMudigonda/html-reporter-github-pages)
