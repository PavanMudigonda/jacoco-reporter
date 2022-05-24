#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

## Make sure any modules we depend on are installed
$modulesToInstall = @(
    'GitHubActions'
)

$modulesToInstall | ForEach-Object {
    if (-not (Get-Module -ListAvailable -All $_)) {
        Write-Output "Module [$_] not found, INSTALLING..."
        Install-Module $_ -Force
    }
}

## Import dependencies
Import-Module GitHubActions -Force

Write-ActionInfo "Running from [$($PSScriptRoot)]"

function splitListInput { $args[0] -split ',' | % { $_.Trim() } }
function writeListInput { $args[0] | % { Write-ActionInfo "    - $_" } }

$inputs = @{
    coverage_report_name = Get-ActionInput coverage_report_name
    coverage_report_title = Get-ActionInput coverage_report_title
    coverage_results_path = Get-ActionInput coverage_results_path -Required
    github_token       = Get-ActionInput github_token -Required
    skip_check_run     = Get-ActionInput skip_check_run
    minimum_coverage   = Get-ActionInput minimum_coverage
    fail_below_threshold = Get-ActionInput fail_below_threshold
    publish_only_summary = Get-ActionInput publish_only_summary
}

$test_results_dir = Join-Path $PWD _TMP
Write-ActionInfo "Creating test results space"
mkdir $test_results_dir
Write-ActionInfo $test_results_dir
$script:coverage_report_path = Join-Path $test_results_dir coverage-results.md
$script:coverage_summary_path = Join-Path $test_results_dir coverage-summary.md
$script:publish_only_summary = $inputs.publish_only_summary
$script:skip_check_run = $inputs.skip_check_run

# Feature 1
function Build-CoverageReport
{
    Write-ActionInfo "Building human-readable code-coverage report"
    $script:coverage_report_name = $inputs.coverage_report_name
    $script:coverage_report_title = $inputs.coverage_report_title
    $script:coverage_results_path = $inputs.coverage_results_path

    if (-not $script:coverage_report_name) {
        $script:coverage_report_name = "COVERAGE_RESULTS_$([datetime]::Now.ToString('yyyyMMdd_hhmmss'))"
    }
    if (-not $coverage_report_title) {
        $script:coverage_report_title = $report_name
    }

        $script:coverage_report_path = Join-Path $test_results_dir coverage-results.md
        & "$PSScriptRoot/jacoco-report/jacocoxml2md.ps1" -Verbose `
            -xmlFile $script:coverage_results_path `
            -mdFile $script:coverage_report_path -xslParams @{
                reportTitle = $script:coverage_report_title
            }

        & "$PSScriptRoot/jacoco-report/embedmissedlines.ps1" -mdFile $script:coverage_report_path

}

#Feature# 2 (added to handle 65k chars limitation on Github API scenario)
function Build-CoverageSummaryReport
{
    Write-ActionInfo "Building human-readable code-coverage report"
    $script:coverage_report_name = $inputs.coverage_report_name
    $script:coverage_report_title = $inputs.coverage_report_title
    $script:coverage_results_path = $inputs.coverage_results_path

    if (-not $script:coverage_report_name) {
        $script:coverage_report_name = "COVERAGE_RESULTS_$([datetime]::Now.ToString('yyyyMMdd_hhmmss'))"
    }
    if (-not $coverage_report_title) {
        $script:coverage_report_title = $report_name
    }

    $script:coverage_report_path = Join-Path $test_results_dir coverage-results.md
    & "$PSScriptRoot/jacoco-report/jacocoxmlsummary2md.ps1" -Verbose `
        -xmlFile $script:coverage_results_path `
        -mdFile $script:coverage_report_path -xslParams @{
            reportTitle = $script:coverage_report_title
        }
}

#Feature 3. Added to support Github Job Summaries
function Build-SummaryReport
{
    Write-ActionInfo "Building human-readable code-coverage report"
    $script:coverage_report_name = $inputs.coverage_report_name
    $script:coverage_report_title = $inputs.coverage_report_title
    $script:coverage_results_path = $inputs.coverage_results_path

    if (-not $script:coverage_report_name) {
        $script:coverage_report_name = "COVERAGE_RESULTS_$([datetime]::Now.ToString('yyyyMMdd_hhmmss'))"
    }
    if (-not $coverage_report_title) {
        $script:coverage_report_title = $report_name
    }

    $script:coverage_summary_path = Join-Path $test_results_dir coverage-summary.md
    & "$PSScriptRoot/jacoco-report/buildsummary2md.ps1" -Verbose `
        -xmlFile $script:coverage_results_path `
        -mdFile $script:coverage_summary_path -xslParams @{
            reportTitle = $script:coverage_report_title
        }
}

function Publish-ToCheckRun {
    param(
        [string]$reportData,
        [string]$reportName,
        [string]$reportTitle
    )

    Write-ActionInfo "Publishing Report to GH Workflow"

    $ghToken = $inputs.github_token
    $ctx = Get-ActionContext
    $repo = Get-ActionRepo
    $repoFullName = "$($repo.Owner)/$($repo.Repo)"

    Write-ActionInfo "Resolving REF"
    $ref = $ctx.Sha
    if ($ctx.EventName -eq 'pull_request') {
        Write-ActionInfo "Resolving PR REF"
        $ref = $ctx.Payload.pull_request.head.sha
        if (-not $ref) {
            Write-ActionInfo "Resolving PR REF as AFTER"
            $ref = $ctx.Payload.after
        }
    }
    if (-not $ref) {
        Write-ActionError "Failed to resolve REF"
        exit 1
    }
    Write-ActionInfo "Resolved REF as $ref"
    Write-ActionInfo "Resolve Repo Full Name as $repoFullName"

    Write-ActionInfo "Adding Check Run"
    $url = "https://api.github.com/repos/$repoFullName/check-runs"
    $hdr = @{
        Accept = 'application/vnd.github.antiope-preview+json'
        Authorization = "token $ghToken"
    }
    $bdy = @{
        name       = $reportName
        head_sha   = $ref
        status     = 'completed'
        conclusion = 'neutral'
        output     = @{
            title   = $reportTitle
            summary = "This run completed at ``$([datetime]::Now)``"
            text    = $ReportData
        }
    }
    Invoke-WebRequest -Headers $hdr $url -Method Post -Body ($bdy | ConvertTo-Json)
}


Write-ActionInfo "Publishing Report to GH Workflow"
$coverage_results_path = $inputs.coverage_results_path
if ($inputs.skip_check_run -ne $true -and $inputs.publish_only_summary -eq $true )
    {
        Build-CoverageSummaryReport

        $coverageSummaryData = [System.IO.File]::ReadAllText($script:coverage_report_path)

        Publish-ToCheckRun -ReportData $coverageSummaryData -ReportName $coverage_report_name -ReportTitle $coverage_report_title

        Set-ActionOutput -Name coverageSummary -Value $coverageSummaryData
    }
elseif ($inputs.skip_check_run -ne $true -and $inputs.publish_only_summary -ne $true )
    {
        Build-CoverageReport

        $coverageSummaryData = [System.IO.File]::ReadAllText($script:coverage_report_path)

        Publish-ToCheckRun -ReportData $coverageSummaryData -ReportName $coverage_report_name -ReportTitle $coverage_report_title

        Set-ActionOutput -Name coverageSummary -Value $coverageSummaryData

    }
elseif ($inputs.skip_check_run -eq $true -and $inputs.publish_only_summary -eq $true )
    {

        Build-CoverageSummaryReport

        Build-SummaryReport

        $coverageSummary = [System.IO.File]::ReadAllText($script:coverage_summary_path)

        Set-ActionOutput -Name coverageSummary -Value $coverageSummary

    }
else {

        Build-CoverageReport

        Build-SummaryReport

        $coverageSummary = [System.IO.File]::ReadAllText($script:coverage_summary_path)

        Set-ActionOutput -Name coverageSummary -Value $coverageSummary

    }
$coverageXmlData = Select-Xml -Path $coverage_results_path -XPath "/report/counter[@type='LINE']"
$coveredLines = $coverageXmlData.Node.covered
Write-Host "Covered Lines: $coveredLines"
$missedLines = $coverageXmlData.Node.missed
$totalLines = $coverageXmlData.Node.covered + $coverageXmlData.Node.missed
Write-Host "Missed Lines: $missedLines"
if ($missedLines -eq 0)
    {
    $coveragePercentage = 100
    }
elseif ($coveredLines -eq 0)
    {
    $coveragePercentage = 0
    }
elseif ($coveredLines -eq 0 -and $missedLines -eq 0)
    {
    $coveragePercentage = 0
    }
else
    {
        $coveragePercentage = [math]::Round( ($coveredLines / ($coveredLines+$missedLines) ) * 100 )
    }

$coveragePercentageString = "{0:P}" -f ($coveredLines / ($coveredLines+$missedLines))

$script:coveragePercentage = $coveragePercentage
$script:coveragePercentage = $coveragePercentageString

Write-Output $coveragePercentage
Write-Output $coveragePercentageString

Set-ActionOutput -Name coveragePercentageString -Value $coveragePercentageString

Set-ActionOutput -Name coverage_percentage -Value ($coveragePercentage)

Set-ActionOutput -Name covered_lines -Value ($coveredLines)
Set-ActionOutput -Name missed_lines -Value ($missedLines)
Set-ActionOutput -Name total_lines -Value ($coveredLines+$missedLines)

if ($inputs.fail_below_threshold -eq "true") {
        Write-ActionInfo "  * fail_below_threshold: true"
    }

if ($coverage_value -lt $inputs.minimum_coverage -and $inputs.fail_below_threshold -eq "true") {
        $script:stepShouldFail = $true
    }

if ($stepShouldFail) {
    Write-ActionInfo "Thowing error as Code Coverage is less than "minimum_coverage" is not met and 'fail_below_threshold' was true."
    throw "Code Coverage is less than Minimum Code Coverage Required"
}
