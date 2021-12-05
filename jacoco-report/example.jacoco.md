
# Coverage Report: Pester (04/16/2021 11:51:47)

* Pester (04/16/2021 11:51:47)

Outcome: 98.43% Coverage
         | Lines Covered: 191
         | Lines Missed: 3

## Details:

    
### src

<details>
    <summary>
:x: ChangelogManagement.psm1
    </summary>

        
#### Lines Missed:
        
- Line #4
```
        . $PrivateFile.FullName
```
</details>

    
### src/public

<details>
    <summary>
:heavy_check_mark: Add-ChangelogData.ps1
    </summary>

        
#### All Lines Covered!
        
</details>

    

<details>
    <summary>
:heavy_check_mark: ConvertFrom-Changelog.ps1
    </summary>

        
#### All Lines Covered!
        
</details>

    

<details>
    <summary>
:heavy_check_mark: Get-ChangelogData.ps1
    </summary>

        
#### All Lines Covered!
        
</details>

    

<details>
    <summary>
:heavy_check_mark: New-Changelog.ps1
    </summary>

        
#### All Lines Covered!
        
</details>

    

<details>
    <summary>
:x: Update-Changelog.ps1
    </summary>

        
#### Lines Missed:
        
- Line #79
```
            throw "You must be running in GitHub Actions to use GitHub LinkMode"
```
- Line #89
```
            throw "You must be running in Azure Pipelines to use AzureDevOps LinkMode"
```
</details>

    
