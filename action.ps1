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

# Write a multiline value to GITHUB_OUTPUT using the heredoc delimiter syntax
# required for values that contain newlines (Set-ActionOutput does not support this).
function Set-MultilineOutput([string]$name, [string]$value) {
    if ($env:GITHUB_OUTPUT) {
        $delim = [System.Guid]::NewGuid().ToString('N')
        Add-Content -Path $env:GITHUB_OUTPUT -Value "$name<<$delim"
        Add-Content -Path $env:GITHUB_OUTPUT -Value $value
        Add-Content -Path $env:GITHUB_OUTPUT -Value $delim
    }
}

## ── Inputs ────────────────────────────────────────────────────────────────────

$inputs = @{
    coverage_report_name  = Get-ActionInput coverage_report_name
    coverage_report_title = Get-ActionInput coverage_report_title
    coverage_results_path = Get-ActionInput coverage_results_path -Required
    github_token          = Get-ActionInput github_token
    ghes_api_endpoint     = Get-ActionInput ghes_api_endpoint
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

# Support comma-separated paths for multi-module projects.
$script:coverage_results_paths = @(
    $inputs.coverage_results_path -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
)
Write-ActionInfo "Coverage file(s): $($script:coverage_results_paths -join ', ')"

$script:coverage_report_name  = $inputs.coverage_report_name
$script:coverage_report_title = $inputs.coverage_report_title

if (-not $script:coverage_report_name) {
    $script:coverage_report_name = "COVERAGE_RESULTS_$([datetime]::Now.ToString('yyyyMMdd_hhmmss'))"
}
if (-not $script:coverage_report_title) {
    $script:coverage_report_title = $script:coverage_report_name
}

## ── Report Builders ───────────────────────────────────────────────────────────

function Build-CoverageReport {
    Write-ActionInfo "Building full code-coverage report ($($script:coverage_results_paths.Count) module(s))"
    $combined = [System.Text.StringBuilder]::new()
    $i = 0
    foreach ($xmlPath in $script:coverage_results_paths) {
        $i++
        $tempMd = Join-Path $test_results_dir "module-full-$i.md"
        & "$PSScriptRoot/jacoco-report/jacocoxml2md.ps1" -Verbose `
            -xmlFile $xmlPath `
            -mdFile  $tempMd `
            -xslParams @{ reportTitle = $script:coverage_report_title }
        & "$PSScriptRoot/jacoco-report/embedmissedlines.ps1" -mdFile $tempMd
        $combined.AppendLine([System.IO.File]::ReadAllText($tempMd)) | Out-Null
    }
    [System.IO.File]::WriteAllText($script:coverage_report_path, $combined.ToString())
}

function Build-CoverageSummaryReport {
    Write-ActionInfo "Building summary code-coverage report ($($script:coverage_results_paths.Count) module(s))"
    $combined = [System.Text.StringBuilder]::new()
    $i = 0
    foreach ($xmlPath in $script:coverage_results_paths) {
        $i++
        $tempMd = Join-Path $test_results_dir "module-summary-$i.md"
        & "$PSScriptRoot/jacoco-report/jacocoxmlsummary2md.ps1" -Verbose `
            -xmlFile $xmlPath `
            -mdFile  $tempMd `
            -xslParams @{ reportTitle = $script:coverage_report_title }
        $combined.AppendLine([System.IO.File]::ReadAllText($tempMd)) | Out-Null
    }
    [System.IO.File]::WriteAllText($script:coverage_report_path, $combined.ToString())
}

function Build-SummaryReport {
    Write-ActionInfo "Building GitHub Job Summary report ($($script:coverage_results_paths.Count) module(s))"
    $combined = [System.Text.StringBuilder]::new()
    $i = 0
    foreach ($xmlPath in $script:coverage_results_paths) {
        $i++
        $tempMd = Join-Path $test_results_dir "module-jobsummary-$i.md"
        & "$PSScriptRoot/jacoco-report/buildsummary2md.ps1" -Verbose `
            -xmlFile $xmlPath `
            -mdFile  $tempMd `
            -xslParams @{ reportTitle = $script:coverage_report_title }
        $combined.AppendLine([System.IO.File]::ReadAllText($tempMd)) | Out-Null
    }
    [System.IO.File]::WriteAllText($script:coverage_summary_path, $combined.ToString())
}

## ── Coverage Analysis ─────────────────────────────────────────────────────────

function Parse-CoverageXML {
    # Sum LINE counters across all modules (multi-module support).
    $script:coveredLines = 0
    $script:missedLines  = 0
    foreach ($xmlPath in $script:coverage_results_paths) {
        $node = (Select-Xml -Path $xmlPath -XPath "/report/counter[@type='LINE']").Node
        $script:coveredLines += [int]$node.covered
        $script:missedLines  += [int]$node.missed
    }
    $script:totalLines = $script:coveredLines + $script:missedLines
    Write-ActionInfo "  Covered : $script:coveredLines"
    Write-ActionInfo "  Missed  : $script:missedLines"
    Write-ActionInfo "  Total   : $script:totalLines"
    Write-ActionInfo "  Note    : percentages are based on LINE coverage, not INSTRUCTION or BRANCH coverage"
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
    $script:status = 'success'
    $script:level  = 'notice'

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
        # Write directly to GITHUB_OUTPUT — Set-ActionOutput in older GitHubActions
        # module versions uses the deprecated ::set-output:: workflow command.
        if ($env:GITHUB_OUTPUT) {
            Add-Content -Path $env:GITHUB_OUTPUT -Value "$($kv.Key)=$($kv.Value)"
        }
    }

    # coverageSummary is multiline markdown — must use heredoc delimiter syntax
    # in GITHUB_OUTPUT to avoid "Invalid format" errors.
    $summaryContent = [System.IO.File]::ReadAllText($script:coverage_report_path)
    Set-MultilineOutput -name 'coverageSummary' -value $summaryContent
}

## ── GitHub Check Run ──────────────────────────────────────────────────────────

# GitHub Check Run API has a ~65k character limit on the `text` field.
$script:CHECKRUN_CHAR_LIMIT = 60000

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

    # GHES support: use provided endpoint, fall back to github.com.
    $apiBase = if ($inputs.ghes_api_endpoint -ne '') {
        $inputs.ghes_api_endpoint.TrimEnd('/')
    } else {
        'https://api.github.com'
    }
    Write-ActionInfo "  API  : $apiBase"

    $hdr = @{
        Accept        = 'application/vnd.github+json'
        Authorization = "token $ghToken"
    }

    $outputBlock = @{
        title   = "Code Coverage $coveragePercentage"
        summary = "Run completed at ``$([datetime]::Now)``"
        text    = $reportData
    }

    # POST body: head_sha is REQUIRED by the create endpoint.
    $postBody = @{
        name       = $reportName
        head_sha   = $ref
        status     = 'completed'
        conclusion = $outcome
        output     = $outputBlock
    }

    # PATCH body: head_sha is NOT accepted by the update endpoint (causes 422).
    $patchBody = @{
        name       = $reportName
        status     = 'completed'
        conclusion = $outcome
        output     = $outputBlock
    }

    # Upsert: update existing check run instead of creating a duplicate.
    $checkName  = [System.Uri]::EscapeDataString($reportName)
    $listUrl    = "$apiBase/repos/$repoFullName/commits/$ref/check-runs?check_name=$checkName&per_page=1"
    $existingId = $null
    try {
        $listResp     = Invoke-WebRequest -Headers $hdr $listUrl -Method Get
        $existingRuns = ($listResp.Content | ConvertFrom-Json).check_runs
        if ($existingRuns.Count -gt 0) {
            $existingId = $existingRuns[0].id
        }
    } catch {
        # Not fatal — fall through to create a new one.
    }

    if ($existingId) {
        Write-ActionInfo "  Updating existing Check Run: $existingId"
        $url = "$apiBase/repos/$repoFullName/check-runs/$existingId"
        Invoke-WebRequest -Headers $hdr $url -Method Patch -ContentType 'application/json' -Body ($patchBody | ConvertTo-Json -Depth 5)
    } else {
        Write-ActionInfo "  Creating new Check Run"
        $url = "$apiBase/repos/$repoFullName/check-runs"
        Invoke-WebRequest -Headers $hdr $url -Method Post -ContentType 'application/json' -Body ($postBody | ConvertTo-Json -Depth 5)
    }
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

    # Auto-fallback: if the full report exceeds GitHub's ~65k char API limit,
    # automatically rebuild and use the summary report instead.
    if ($reportData.Length -gt $script:CHECKRUN_CHAR_LIMIT -and -not $publishOnlySummary) {
        Write-ActionWarning "Report is $($reportData.Length) chars, exceeding the $($script:CHECKRUN_CHAR_LIMIT)-char GitHub Check Run limit. Switching to summary report automatically."
        Build-CoverageSummaryReport
        $reportData = [System.IO.File]::ReadAllText($script:coverage_report_path)
    }

    Publish-ToCheckRun `
        -ReportData         $reportData `
        -ReportName         $script:coverage_report_name `
        -ReportTitle        $script:coverage_report_title `
        -outcome            $script:status `
        -coveragePercentage $script:coveragePercentageString
}

# Step 4 ── Enforce quality gate (throws on failure when configured)
Enforce-QualityGate
