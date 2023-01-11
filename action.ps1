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
    coverage_report_name  = Get-ActionInput coverage_report_name
    coverage_report_title = Get-ActionInput coverage_report_title
    coverage_results_path = Get-ActionInput coverage_results_path -Required
    github_token          = Get-ActionInput github_token -Required
    skip_check_run        = Get-ActionInput skip_check_run
    minimum_coverage      = Get-ActionInput minimum_coverage
    fail_below_threshold  = Get-ActionInput fail_below_threshold
    publish_only_summary  = Get-ActionInput publish_only_summary
}

$test_results_dir = Join-Path $PWD _TMP
Write-ActionInfo "Creating test results space"
mkdir $test_results_dir
Write-ActionInfo $test_results_dir
$script:coverage_report_path  = Join-Path $test_results_dir coverage-results.md
$script:coverage_summary_path = Join-Path $test_results_dir coverage-summary.md
$script:publish_only_summary  = $inputs.publish_only_summary
$script:skip_check_run        = $inputs.skip_check_run

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


function Parse-CoverageXML {
    # Parse XML
    $coverageXmlData = Select-Xml -Path $script:coverage_results_path -XPath "/report/counter[@type='LINE']"
    $script:coveredLines = [int]$coverageXmlData.Node.covered
    Write-Host "Covered Lines: $coveredLines"
    $script:missedLines = [int]$coverageXmlData.Node.missed
    $script:totalLines = [int]($coveredLines+$missedLines)
    Write-Host "Missed Lines: $missedLines"
    Write-Host "Total Lines: $totalLines"
}

function Format-Percentage {
    # Format Percentage
    if ($script:missedLines -eq 0)
        {
            $coveragePercentage = 100
            $script:coveragePercentage = 100
            Write-Output "Coverage: $coveragePercentage"
            $script:coveragePercentageString = "{0:p2}" -f ($coveragePercentage/100)
        }
    elseif ($script:coveredLines -eq 0)
        {
            $coveragePercentage = 0
            $script:coveragePercentage = 0
            Write-Output "Coverage: $coveragePercentage"
            $script:coveragePercentageString = "{0:p2}" -f ($coveragePercentage)
        }
    elseif ($coveredLines -eq 0 -and $missedLines -eq 0)
        {
            $coveragePercentage = 0
            $script:coveragePercentage = 0
            Write-Output "Coverage: $coveragePercentage"
            $script:coveragePercentageString = "{0:p2}" -f ($coveragePercentage)
        }
    else
        {
            $coveragePercentage = [math]::Round( (($script:coveredLines/($script:coveredLines+$script:missedLines) ) * 100 ), 2)
            $script:coveragePercentage = [math]::Round( (($script:coveredLines/($script:coveredLines+$script:missedLines) ) * 100 ), 2)
            Write-Output "Coverage: $coveragePercentage"
            $script:coveragePercentageString = "{0:p2}" -f ($coveragePercentage/100)
        }
}


function Set-Output {
    # Set Output

    Set-ActionVariable -Name coveragePercentageString -Value ($script:coveragePercentageString)
    Set-ActionVariable -Name coveragePercentage -Value ($script:coveragePercentage)
    Set-ActionVariable -Name coverage_percentage -Value ($script:coveragePercentage)
    Set-ActionVariable -Name covered_lines -Value ($script:coveredLines)
    Set-ActionVariable -Name missed_lines -Value ($script:missedLines)
    Set-ActionVariable -Name total_lines -Value ($coveredLines+$missedLines)
    Set-ActionOutput -Name coveragePercentageString -Value ($script:coveragePercentageString)
    Set-ActionOutput -Name coveragePercentage -Value ($script:coveragePercentage)
    Set-ActionOutput -Name coverage_percentage -Value ($script:coveragePercentage)
    Set-ActionOutput -Name covered_lines -Value ($script:coveredLines)
    Set-ActionOutput -Name missed_lines -Value ($script:missedLines)
    Set-ActionOutput -Name total_lines -Value ($script:coveredLines+$missedLines)

}

function Set-Outcome {
    if ($inputs.fail_below_threshold -eq "true") {
            Write-ActionInfo "  * fail_below_threshold: true"
        }

    if (($script:coveragePercentage -lt $inputs.minimum_coverage) -and ($inputs.fail_below_threshold -eq "true")) {
            $script:status = "failure"
            $script:level = "warning"
            $script:messageToDisplay = "Code Coverage $script:coveragePercentageString"
        }

    if (($script:coveragePercentage -ge $inputs.minimum_coverage) -and ($inputs.fail_below_threshold -eq "true")) {
            $script:status = "success"
            $script:level = "notice"
            $script:messageToDisplay = "Code Coverage $script:coveragePercentageString"
        }

    if (($script:coveragePercentage -ge $inputs.minimum_coverage) -and ($inputs.fail_below_threshold -eq "false")) {
            $script:status = "success"
            $script:level = "notice"
            $script:messageToDisplay = "Code Coverage $script:coveragePercentageString"
        }

    if (($script:coveragePercentage -ge $inputs.minimum_coverage) -and ($inputs.fail_below_threshold -eq "")) {
            $script:status = "success"
            $script:level = "notice"
            $script:messageToDisplay = "Code Coverage $script:coveragePercentageString"
        }

    if (($script:coveragePercentage -lt $inputs.minimum_coverage) -and ($inputs.fail_below_threshold -eq "false")) {
            $script:status = "success"
            $script:level = "notice"
            $script:messageToDisplay = "Code Coverage $script:coveragePercentageString"
        }
        
    if (($script:coveragePercentage -lt $inputs.minimum_coverage) -and ($inputs.fail_below_threshold -eq "")) {
            $script:status = "success"
            $script:level = "notice"
            $script:messageToDisplay = "Code Coverage $script:coveragePercentageString"
        }
    if(($inputs.minimum_coverage -eq "") -or ($inputs.fail_below_threshold -eq "")){
        $script:status = "success"
        $script:level = 'notice'
        $script:messageToDisplay = "Code Coverage $script:coveragePercentageString"
    }
}

# Enforce Quality Gate

function Enforce-QualityGate {
    if ($inputs.fail_below_threshold -eq "true") {
            Write-ActionInfo "  * fail_below_threshold: true"
        }

    if ($coveragePercentage -lt $inputs.minimum_coverage -and $inputs.fail_below_threshold -eq "true") {
            $script:stepShouldFail = $true
        }

    if ($stepShouldFail) {
        Write-ActionInfo "Thowing error as Code Coverage is less than "minimum_coverage" is not met and 'fail_below_threshold' was true."
        throw "Code Coverage is less than Minimum Code Coverage Required"
    }
}

# #Issue 26: FEATURE REQUEST: Display Coverage Percent along with Check

# function Update-PRCheck {
#     param(
#         [string]$reportData,
#         [string]$reportName,
#         [string]$reportTitle
#     )
    
#     Set-Outcome
    
#     $ghToken = $inputs.github_token
#     $ctx = Get-ActionContext
#     $repo = Get-ActionRepo
#     $repoFullName = "$($repo.Owner)/$($repo.Repo)"    
#     Write-ActionInfo "Resolved REF as $ref"
#     Write-ActionInfo "Resolve Repo Full Name as $repoFullName"
#     Write-ActionInfo "Update Annotation Check to: $checkId"
#     $checkId = $script:checkId
#     Write-ActionInfo "checkId: $checkId"
#     $url = "https://api.github.com/repos/$repoFullName/check-runs/$checkId"
#     $hdr = @{
#         Accept = 'application/vnd.github+json'
#         Authorization = "token $ghToken"
#     }
#     $bdy = @{
#         name       = $reportName
#         status     = 'completed'
#         conclusion = $script:outcome
#         output     = @{
#             title   = $reportTitle
#             summary = "This run completed at ``$([datetime]::Now)``"
#             text    = $ReportData
#         }
#     }
#     Invoke-WebRequest -Headers $hdr $url -Method Patch -Body ($bdy | ConvertTo-Json)
# }

# Publishing Report to GH Workflow
# Function to Publish Check Run with Neutral Status # Round 1
function Publish-ToCheckRun {
    param(
        [string]$reportData,
        [string]$reportName,
        [string]$reportTitle,
        [string]$outcome,
        [string]$coveragePercentage
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
        Accept = 'application/vnd.github+json'
        Authorization = "token $ghToken"
    }
    $bdy = @{
        name       = $reportName
        head_sha   = $ref
        status     = 'completed'
        conclusion = $outcome
        output     = @{
            title   = "Code Coverage $coveragePercentage"
            summary = "This run completed at ``$([datetime]::Now)``"
            text    = $ReportData
        }
    }
    Write-ActionInfo "$hdr"
    Write-ActionInfo $url
    Write-ActionInfo "$bdy"

    Invoke-WebRequest -Headers $hdr $url -Method Post -Body ($bdy | ConvertTo-Json)
    # Grab Check ID
    # $checkId = ( ConvertFrom-Json $response.Content ).id
    # $checkUrl = ( ConvertFrom-Json $response.Content ).url
    # Write-ActionInfo "Check ID: $checkId"
    # Write-ActionInfo "Check ID: $checkUrl"
    # $script:checkUrl = $checkUrl
    # $script:checkId = $checkId
}


Write-ActionInfo "Publishing Report to GH Workflow"
$coverage_results_path = $inputs.coverage_results_path
if ($inputs.skip_check_run -ne $true -and $inputs.publish_only_summary -eq $true )
    {

        Build-CoverageSummaryReport
        
        Parse-CoverageXML
                
        Format-Percentage
        
        Set-Outcome
        
        Set-Output
        
        $coverageSummaryData = [System.IO.File]::ReadAllText($script:coverage_report_path)     
        
        Publish-ToCheckRun -ReportData $coverageSummaryData -ReportName "Code Coverage" -ReportTitle $script:coverage_report_title -outcome $Script:status -coveragePercentage $script:coveragePercentageString
        
#       Update-PRCheck -ReportData $script:coverageSummaryData -ReportName $coverage_report_name -ReportTitle $script:messageToDisplay

        Enforce-QualityGate
        
        # Set-ActionOutput -Name coverageSummary -Value $script:coverageSummaryData
    }
elseif ($inputs.skip_check_run -ne $true -and $inputs.publish_only_summary -ne $true )
    {

        Build-CoverageReport

        Parse-CoverageXML
                
        Format-Percentage
        
        Set-Outcome
        
        Set-Output
        
        $coverageSummaryData = [System.IO.File]::ReadAllText($script:coverage_report_path)

        Publish-ToCheckRun -ReportData $coverageSummaryData -ReportName "Code Coverage" -ReportTitle $script:coverage_report_title -outcome $script:status -coveragePercentage $script:coveragePercentageString

#       Update-PRCheck -ReportData $script:coverageSummaryData -ReportName $coverage_report_name -ReportTitle $script:messageToDisplay

        Enforce-QualityGate
        # Set-ActionOutput -Name coverageSummary -Value $script:coverageSummaryData

    }
elseif ($inputs.skip_check_run -eq $true -and $inputs.publish_only_summary -eq $true )
    {
        
        Build-CoverageSummaryReport

        Build-SummaryReport
        
        Parse-CoverageXML
                
        Format-Percentage

        Set-Outcome
        
        Set-Output
        
        # $coverageSummary = [System.IO.File]::ReadAllText($script:coverage_summary_path)

        Enforce-QualityGate
        # Set-ActionOutput -Name coverageSummary -Value $script:coverageSummary
    }
else {
        Build-CoverageReport

        Build-SummaryReport
        
        Parse-CoverageXML
                
        Format-Percentage
        
        Set-Outcome
        
        Set-Output
        
        # $coverageSummary = [System.IO.File]::ReadAllText($script:coverage_summary_path)
        
        Enforce-QualityGate

        # Set-ActionOutput -Name coverageSummary -Value $script:coverageSummary
    }
    
