#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

## ── Dependencies ──────────────────────────────────────────────────────────────

$modulesToInstall = @('GitHubActions')
$modulesToInstall | ForEach-Object {
    if (-not (Get-Module -ListAvailable -All $_)) {
        Write-Output "Module [$_] not found, INSTALLING..."
        Install-Module $_ -Force
    }
}
Import-Module GitHubActions -Force

Write-ActionInfo "Running from [$($PSScriptRoot)]"

## ── Helpers ───────────────────────────────────────────────────────────────────

# GitHub Actions inputs are always strings; convert explicitly to avoid
# silent coercion bugs (e.g. "false" -ne $true evaluates to $true).
function Parse-Bool([string]$value) { $value -ieq 'true' }

## ── Inputs ────────────────────────────────────────────────────────────────────

$inputs = @{
    coverage_report_name  = Get-ActionInput coverage_report_name
    coverage_report_title = Get-ActionInput coverage_report_title
    coverage_results_path = Get-ActionInput coverage_results_path -Required
    github_token          = Get-ActionInput github_token
    skip_check_run        = Get-ActionInput skip_check_run
    minimum_coverage      = Get-ActionInput minimum_coverage
    fail_below_threshold  = Get-ActionInput fail_below_threshold
    publish_only_summary  = Get-ActionInput publish_only_summary
}

## ── Workspace ─────────────────────────────────────────────────────────────────

$test_results_dir = Join-Path $PWD _TMP
Write-ActionInfo "Creating test results space at: $test_results_dir"
New-Item -ItemType Directory -Force -Path $test_results_dir | Out-Null

$script:coverage_report_path  = Join-Path $test_results_dir coverage-results.md
$script:coverage_summary_path = Join-Path $test_results_dir coverage-summary.md

## ── Report Metadata ───────────────────────────────────────────────────────────

# Resolve once; all Build-* functions share these values.
$script:coverage_report_name  = $inputs.coverage_report_name
$script:coverage_report_title = $inputs.coverage_report_title
$script:coverage_results_path = $inputs.coverage_results_path

if (-not $script:coverage_report_name) {
    $script:coverage_report_name = "COVERAGE_RESULTS_$([datetime]::Now.ToString('yyyyMMdd_hhmmss'))"
}
if (-not $script:coverage_report_title) {
    $script:coverage_report_title = $script:coverage_report_name
}

## ── Report Builders ───────────────────────────────────────────────────────────

function Build-CoverageReport {
    Write-ActionInfo "Building full code-coverage report"
    & "$PSScriptRoot/jacoco-report/Invoke-XslTransform.ps1" `
        -xmlFile   $script:coverage_results_path `
        -xslFile   "$PSScriptRoot/jacoco-report/jacocoxml2md.xsl" `
        -mdFile    $script:coverage_report_path `
        -xslParams @{ reportTitle = $script:coverage_report_title }
    & "$PSScriptRoot/jacoco-report/embedmissedlines.ps1" -mdFile $script:coverage_report_path
}

function Build-CoverageSummaryReport {
    Write-ActionInfo "Building summary code-coverage report"
    & "$PSScriptRoot/jacoco-report/Invoke-XslTransform.ps1" `
        -xmlFile   $script:coverage_results_path `
        -xslFile   "$PSScriptRoot/jacoco-report/jacocoxmlsummary2md.xsl" `
        -mdFile    $script:coverage_report_path `
        -xslParams @{ reportTitle = $script:coverage_report_title }
}

function Build-SummaryReport {
    Write-ActionInfo "Building GitHub Job Summary report"
    & "$PSScriptRoot/jacoco-report/Invoke-XslTransform.ps1" `
        -xmlFile   $script:coverage_results_path `
        -xslFile   "$PSScriptRoot/jacoco-report/buildsummary2md.xsl" `
        -mdFile    $script:coverage_summary_path `
        -xslParams @{ reportTitle = $script:coverage_report_title }
}

## ── Coverage Analysis ─────────────────────────────────────────────────────────

function Parse-CoverageXML {
    $node = (Select-Xml -Path $script:coverage_results_path -XPath "/report/counter[@type='LINE']").Node
    $script:coveredLines = [int]$node.covered
    $script:missedLines  = [int]$node.missed
    $script:totalLines   = $script:coveredLines + $script:missedLines
    Write-ActionInfo "  Covered : $script:coveredLines"
    Write-ActionInfo "  Missed  : $script:missedLines"
    Write-ActionInfo "  Total   : $script:totalLines"
}

function Format-Percentage {
    $script:coveragePercentage = if ($script:coveredLines -eq 0 -and $script:missedLines -eq 0) {
        0
    } elseif ($script:missedLines -eq 0) {
        100
    } elseif ($script:coveredLines -eq 0) {
        0
    } else {
        [math]::Round(($script:coveredLines / $script:totalLines) * 100, 2)
    }
    $script:coveragePercentageString = "{0:p2}" -f ($script:coveragePercentage / 100)
    Write-ActionInfo "Coverage: $script:coveragePercentageString"
}

## ── Outcome & Outputs ─────────────────────────────────────────────────────────

function Set-Outcome {
    # Default to success; only override when threshold enforcement is requested.
    $script:status           = 'success'
    $script:level            = 'notice'
    $script:messageToDisplay = "Code Coverage $script:coveragePercentageString"

    $minCoverage = $inputs.minimum_coverage
    $failBelow   = Parse-Bool $inputs.fail_below_threshold

    if ($minCoverage -ne '' -and $inputs.fail_below_threshold -ne '') {
        Write-ActionInfo "  fail_below_threshold : $failBelow"
        Write-ActionInfo "  minimum_coverage     : $minCoverage%"
        if ($failBelow -and ($script:coveragePercentage -lt [int]$minCoverage)) {
            $script:status = 'failure'
            $script:level  = 'warning'
        }
    }
}

function Set-Outputs {
    # Set both action variables and action outputs for maximum compatibility.
    $pairs = @{
        coveragePercentageString = $script:coveragePercentageString
        coveragePercentage       = $script:coveragePercentage
        coverage_percentage      = $script:coveragePercentage
        covered_lines            = $script:coveredLines
        missed_lines             = $script:missedLines
        total_lines              = $script:totalLines
    }
    foreach ($kv in $pairs.GetEnumerator()) {
        Set-ActionVariable -Name $kv.Key -Value $kv.Value
        Set-ActionOutput   -Name $kv.Key -Value $kv.Value
    }
}

## ── GitHub Check Run ──────────────────────────────────────────────────────────

function Publish-ToCheckRun {
    param(
        [string]$reportData,
        [string]$reportName,
        [string]$reportTitle,
        [string]$outcome,
        [string]$coveragePercentage
    )

    Write-ActionInfo "Publishing Check Run to GitHub"
    $ghToken      = $inputs.github_token
    $ctx          = Get-ActionContext
    $repo         = Get-ActionRepo
    $repoFullName = "$($repo.Owner)/$($repo.Repo)"

    # Resolve the correct commit SHA for push and pull_request events.
    $ref = $ctx.Sha
    if ($ctx.EventName -eq 'pull_request') {
        $ref = $ctx.Payload.pull_request.head.sha
        if (-not $ref) { $ref = $ctx.Payload.after }
    }
    if (-not $ref) {
        Write-ActionError "Failed to resolve commit SHA"
        exit 1
    }
    Write-ActionInfo "  Repo : $repoFullName"
    Write-ActionInfo "  SHA  : $ref"

    $url = "https://api.github.com/repos/$repoFullName/check-runs"
    $hdr = @{
        Accept        = 'application/vnd.github+json'
        Authorization = "token $ghToken"
    }
    $bdy = @{
        name       = $reportName
        head_sha   = $ref
        status     = 'completed'
        conclusion = $outcome
        output     = @{
            title   = "Code Coverage $coveragePercentage"
            summary = "Run completed at ``$([datetime]::Now)``"
            text    = $reportData
        }
    }
    Invoke-WebRequest -Headers $hdr $url -Method Post -Body ($bdy | ConvertTo-Json)
}

## ── Quality Gate ──────────────────────────────────────────────────────────────

function Enforce-QualityGate {
    if ($script:status -eq 'failure') {
        $msg = "Code Coverage $script:coveragePercentageString is below the required minimum of $($inputs.minimum_coverage)%."
        Write-ActionInfo "Quality gate FAILED: $msg"
        throw $msg
    }
    Write-ActionInfo "Quality gate PASSED: $script:coveragePercentageString"
}

## ── Main ──────────────────────────────────────────────────────────────────────

Write-ActionInfo "Starting JaCoCo Reporter"

$skipCheckRun       = Parse-Bool $inputs.skip_check_run
$publishOnlySummary = Parse-Bool $inputs.publish_only_summary

Write-ActionInfo "  skip_check_run       : $skipCheckRun"
Write-ActionInfo "  publish_only_summary : $publishOnlySummary"

# Step 1 ── Build the appropriate report(s)
if ($publishOnlySummary) {
    Build-CoverageSummaryReport
} else {
    Build-CoverageReport
}
if ($skipCheckRun) {
    Build-SummaryReport
}

# Step 2 ── Parse coverage data and compute metrics
Parse-CoverageXML
Format-Percentage
Set-Outcome
Set-Outputs

# Step 3 ── Publish to GitHub Check Run (unless skipped)
if (-not $skipCheckRun) {
    $reportData = [System.IO.File]::ReadAllText($script:coverage_report_path)
    Publish-ToCheckRun `
        -ReportData         $reportData `
        -ReportName         $script:coverage_report_name `
        -ReportTitle        $script:coverage_report_title `
        -outcome            $script:status `
        -coveragePercentage $script:coveragePercentageString
}

# Step 4 ── Enforce quality gate (throws on failure when configured)
Enforce-QualityGate
