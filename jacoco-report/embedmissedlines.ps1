
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$mdFile
)

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
        $filePath   = $parts[1]

        if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
            $filePath = $filePath.Replace('/', '\')
        }

        $matches = @($workspaceFiles | Where-Object { $_.FullName -like "*$filePath" })

        if ($matches.Count -eq 0) {
            Write-Warning "embedmissedlines: source file not found for '$filePath' — skipping line embed"
            $outputData.Add($line)
            continue
        }
        if ($matches.Count -gt 1) {
            Write-Warning "embedmissedlines: multiple files matched '$filePath', using first match: $($matches[0].FullName)"
        }

        $fileContents = Get-Content -Path $matches[0].FullName
        $missedLine   = $fileContents[$lineNumber - 1]

        $outputData.Add($linePrefix)
        $outputData.Add('```')
        $outputData.Add($missedLine)
        $outputData.Add('```')
    } else {
        $outputData.Add($line)
    }
}

Set-Content -Value $outputData -Path $mdFile
