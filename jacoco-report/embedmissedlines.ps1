
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$mdFile
)

# Guard: GITHUB_WORKSPACE must be set; skip embedding gracefully when running locally.
if (-not $env:GITHUB_WORKSPACE) {
    Write-Warning "embedmissedlines: GITHUB_WORKSPACE is not set — skipping source line embedding"
    return
}

$mdData = Get-Content -Path $mdFile

# Build the workspace file index once — avoids an O(n) filesystem scan
# inside the loop for every missed line.
$workspaceFiles = Get-ChildItem -Path "$env:GITHUB_WORKSPACE" -Recurse -File

# Use a List to avoid O(n²) array-copy overhead from PowerShell's += on fixed arrays.
$outputData = [System.Collections.Generic.List[string]]::new()

foreach ($line in $mdData) {
    if ($line -like "- Line #*") {
        $parts      = $line.Split('|')
        $linePrefix = $parts[0]
        $lineNumber = [int]($linePrefix.Split('#')[1])
        $filePath   = $parts[1].Trim()   # Trim whitespace from the parsed path

        if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
            $filePath = $filePath.Replace('/', '\')
        }

        $matched = @($workspaceFiles | Where-Object { $_.FullName -like "*$filePath" })

        if ($matched.Count -eq 0) {
            Write-Warning "embedmissedlines: source file not found for '$filePath' — skipping line embed"
            $outputData.Add($line)
            continue
        }
        if ($matched.Count -gt 1) {
            Write-Warning "embedmissedlines: multiple files matched '$filePath', using first match: $($matched[0].FullName)"
        }

        # Force an array with @() — Get-Content returns a plain string (not an array)
        # for single-line files, causing index access to return individual characters.
        $fileContents = @(Get-Content -Path $matched[0].FullName)

        # Guard: line number from the XML could exceed the actual file length.
        if ($lineNumber -lt 1 -or $lineNumber -gt $fileContents.Count) {
            Write-Warning "embedmissedlines: line $lineNumber is out of range for '$($matched[0].FullName)' ($($fileContents.Count) lines) — skipping"
            $outputData.Add($line)
            continue
        }

        $missedLine = $fileContents[$lineNumber - 1]

        $outputData.Add($linePrefix)
        $outputData.Add('```')
        $outputData.Add($missedLine)
        $outputData.Add('```')
    } else {
        $outputData.Add($line)
    }
}

Set-Content -Value $outputData -Path $mdFile
