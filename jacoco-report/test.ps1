& "$PSScriptRoot/jacocoxml2md.ps1" -Verbose `
            -xmlFile "report.xml" `
            -mdFile "report.md" -xslParams @{
                reportTitle = "test coverage report"
            }