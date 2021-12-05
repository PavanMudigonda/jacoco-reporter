
# Test Report: Pester_2020-08-06_13:23:54

* Date: 2020-08-06
* Time: 13:23:54

Expand the following summaries for more details:

<details>
    <summary> Environment:
    </summary>

| **Env** | |
|--|--|
| **`user`:**          | `ebekker`
| **`cwd`:**           | `C:\local\prj\bek\pwsh-github-action-tools`
| **`os-version`:**    | `10.0.18363`
| **`user-domain`:**   | `EZSHIELD`
| **`machine-name`:**  | `EZS-001388`
| **`nunit-version`:** | `2.5.8.0`
| **`clr-version`:**   | `Unknown`
| **`platform`:**      | `Microsoft Windows 10 Pro|C:\WINDOWS|\Device\Harddisk0\Partition3`



</details>



<details>
    <summary> Outcome: 
        /> | Total Tests: 27 | Passed: 24 | Failed: 3
    </summary>

| **Counters** | |
|-|-|
| **Total:**        | 27
| **Errors:**       | 0
| **Failures:**     | 3
| **Not-run:**      | 0
| **Inconclusive:** | 0
| **Ignored:**      | 0
| **Skipped:**      | 0
| **Invalid:**      | 0



</details>


## Tests:

        
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Set-ActionVariable / Set-ActionVariable.Given valid -Name and -Value, and -SkipLocal

<details>
    <summary>
:x: Set-ActionVariable.Given valid -Name and -Value, and -SkipLocal("varValue1","varName1")
    </summary>

Given valid -Name and -Value, and -SkipLocal

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Set-ActionVariable / Set-ActionVariable.Given valid -Name and -Value, and -SkipLocal`
| **Name:**          | `Set-ActionVariable.Given valid -Name and -Value, and -SkipLocal("varValue1","varName1")`
| **Outcome:**       | `Failure` :x:
| **Time:**          | `0.1167` seconds

        

<details>
    <summary>Error Message:</summary>

```text
Expected $null or empty, but got varValue1.
at [System.Environment]::GetEnvironmentVariable($Name) | Should -BeNullOrEmpty, C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1:30
```
</details>

<details>
    <summary>Error Stack Trace:</summary>

```text
at <ScriptBlock>, C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1:30
```
</details>

    
</details>
    
    

<details>
    <summary>
:x: Set-ActionVariable.Given valid -Name and -Value, and -SkipLocal("var value 2","var name 2")
    </summary>

Given valid -Name and -Value, and -SkipLocal

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Set-ActionVariable / Set-ActionVariable.Given valid -Name and -Value, and -SkipLocal`
| **Name:**          | `Set-ActionVariable.Given valid -Name and -Value, and -SkipLocal("var value 2","var name 2")`
| **Outcome:**       | `Failure` :x:
| **Time:**          | `0.0148` seconds

        

<details>
    <summary>Error Message:</summary>

```text
Expected $null or empty, but got var value 2.
at [System.Environment]::GetEnvironmentVariable($Name) | Should -BeNullOrEmpty, C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1:30
```
</details>

<details>
    <summary>Error Stack Trace:</summary>

```text
at <ScriptBlock>, C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1:30
```
</details>

    
</details>
    
    

<details>
    <summary>
:x: Set-ActionVariable.Given valid -Name and -Value, and -SkipLocal("::set-env name=var%2Cname%3B3::var,value;3
","var,value;3","var,name;3")
    </summary>

Given valid -Name and -Value, and -SkipLocal

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Set-ActionVariable / Set-ActionVariable.Given valid -Name and -Value, and -SkipLocal`
| **Name:**          | `Set-ActionVariable.Given valid -Name and -Value, and -SkipLocal("::set-env name=var%2Cname%3B3::var,value;3
","var,value;3","var,name;3")`
| **Outcome:**       | `Failure` :x:
| **Time:**          | `0.031` seconds

        

<details>
    <summary>Error Message:</summary>

```text
Expected $null or empty, but got var,value;3.
at [System.Environment]::GetEnvironmentVariable($Name) | Should -BeNullOrEmpty, C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1:30
```
</details>

<details>
    <summary>Error Stack Trace:</summary>

```text
at <ScriptBlock>, C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1:30
```
</details>

    
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Set-ActionVariable / Set-ActionVariable.Given valid -Name and -Value, and NOT -SkipLocal

<details>
    <summary>
:heavy_check_mark: Set-ActionVariable.Given valid -Name and -Value, and NOT -SkipLocal("varValue1","varName1")
    </summary>

Given valid -Name and -Value, and NOT -SkipLocal

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Set-ActionVariable / Set-ActionVariable.Given valid -Name and -Value, and NOT -SkipLocal`
| **Name:**          | `Set-ActionVariable.Given valid -Name and -Value, and NOT -SkipLocal("varValue1","varName1")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.004` seconds

        
</details>
    
    

<details>
    <summary>
:heavy_check_mark: Set-ActionVariable.Given valid -Name and -Value, and NOT -SkipLocal("var value 2","var name 2")
    </summary>

Given valid -Name and -Value, and NOT -SkipLocal

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Set-ActionVariable / Set-ActionVariable.Given valid -Name and -Value, and NOT -SkipLocal`
| **Name:**          | `Set-ActionVariable.Given valid -Name and -Value, and NOT -SkipLocal("var value 2","var name 2")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0055` seconds

        
</details>
    
    

<details>
    <summary>
:heavy_check_mark: Set-ActionVariable.Given valid -Name and -Value, and NOT -SkipLocal("::set-env name=var%2Cname%3B3::var,value;3
","var,value;3","var,name;3")
    </summary>

Given valid -Name and -Value, and NOT -SkipLocal

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Set-ActionVariable / Set-ActionVariable.Given valid -Name and -Value, and NOT -SkipLocal`
| **Name:**          | `Set-ActionVariable.Given valid -Name and -Value, and NOT -SkipLocal("::set-env name=var%2Cname%3B3::var,value;3
","var,value;3","var,name;3")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0139` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Add-ActionSecretMask

<details>
    <summary>
:heavy_check_mark: Add-ActionSecretMask.Given a valid -Secret
    </summary>

Given a valid -Secret

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Add-ActionSecretMask`
| **Name:**          | `Add-ActionSecretMask.Given a valid -Secret`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0133` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Add-ActionPath

<details>
    <summary>
:heavy_check_mark: Add-ActionPath.Given a valid -Path and -SkipLocal
    </summary>

Given a valid -Path and -SkipLocal

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Add-ActionPath`
| **Name:**          | `Add-ActionPath.Given a valid -Path and -SkipLocal`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0045` seconds

        
</details>
    
    

<details>
    <summary>
:heavy_check_mark: Add-ActionPath.Given a valid -Path and NOT -SkipLocal
    </summary>

Given a valid -Path and NOT -SkipLocal

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Add-ActionPath`
| **Name:**          | `Add-ActionPath.Given a valid -Path and NOT -SkipLocal`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0078` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInput / Get-ActionInput.Given valid -Name

<details>
    <summary>
:heavy_check_mark: Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"input1")
    </summary>

Given valid -Name

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInput / Get-ActionInput.Given valid -Name`
| **Name:**          | `Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"input1")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0096` seconds

        
</details>
    
    

<details>
    <summary>
:heavy_check_mark: Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"INPUT1")
    </summary>

Given valid -Name

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInput / Get-ActionInput.Given valid -Name`
| **Name:**          | `Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"INPUT1")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.012` seconds

        
</details>
    
    

<details>
    <summary>
:heavy_check_mark: Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"Input1")
    </summary>

Given valid -Name

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInput / Get-ActionInput.Given valid -Name`
| **Name:**          | `Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"Input1")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.009` seconds

        
</details>
    
    

<details>
    <summary>
:heavy_check_mark: Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"input2")
    </summary>

Given valid -Name

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInput / Get-ActionInput.Given valid -Name`
| **Name:**          | `Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"input2")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0093` seconds

        
</details>
    
    

<details>
    <summary>
:heavy_check_mark: Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"INPUT2")
    </summary>

Given valid -Name

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInput / Get-ActionInput.Given valid -Name`
| **Name:**          | `Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"INPUT2")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0074` seconds

        
</details>
    
    

<details>
    <summary>
:heavy_check_mark: Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"Input2")
    </summary>

Given valid -Name

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInput / Get-ActionInput.Given valid -Name`
| **Name:**          | `Get-ActionInput.Given valid -Name(System.Collections.Hashtable,"Input2")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0079` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInputs

<details>
    <summary>
:heavy_check_mark: Get-ActionInputs.Given 2 predefined inputs
    </summary>

Given 2 predefined inputs

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInputs`
| **Name:**          | `Get-ActionInputs.Given 2 predefined inputs`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.005` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInputs / Get-ActionInputs.Given 2 predefined inputs, and a -Name in any case

<details>
    <summary>
:heavy_check_mark: Get-ActionInputs.Given 2 predefined inputs, and a -Name in any case(System.Collections.Hashtable,"InPut1")
    </summary>

Given 2 predefined inputs, and a -Name in any case

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInputs / Get-ActionInputs.Given 2 predefined inputs, and a -Name in any case`
| **Name:**          | `Get-ActionInputs.Given 2 predefined inputs, and a -Name in any case(System.Collections.Hashtable,"InPut1")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0124` seconds

        
</details>
    
    

<details>
    <summary>
:heavy_check_mark: Get-ActionInputs.Given 2 predefined inputs, and a -Name in any case(System.Collections.Hashtable,"InPut2")
    </summary>

Given 2 predefined inputs, and a -Name in any case

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInputs / Get-ActionInputs.Given 2 predefined inputs, and a -Name in any case`
| **Name:**          | `Get-ActionInputs.Given 2 predefined inputs, and a -Name in any case(System.Collections.Hashtable,"InPut2")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0079` seconds

        
</details>
    
    

<details>
    <summary>
:heavy_check_mark: Get-ActionInputs.Given 2 predefined inputs, and a -Name in any case(System.Collections.Hashtable,"InPut3")
    </summary>

Given 2 predefined inputs, and a -Name in any case

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Get-ActionInputs / Get-ActionInputs.Given 2 predefined inputs, and a -Name in any case`
| **Name:**          | `Get-ActionInputs.Given 2 predefined inputs, and a -Name in any case(System.Collections.Hashtable,"InPut3")`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0118` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Set-ActionOuput

<details>
    <summary>
:heavy_check_mark: Set-ActionOuput.Given a valid -Name and -Value
    </summary>

Given a valid -Name and -Value

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Set-ActionOuput`
| **Name:**          | `Set-ActionOuput.Given a valid -Name and -Value`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0046` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Write-ActionDebug

<details>
    <summary>
:heavy_check_mark: Write-ActionDebug.Given a valid -Message
    </summary>

Given a valid -Message

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Write-ActionDebug`
| **Name:**          | `Write-ActionDebug.Given a valid -Message`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0028` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Write-ActionError

<details>
    <summary>
:heavy_check_mark: Write-ActionError.Given a valid -Message
    </summary>

Given a valid -Message

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Write-ActionError`
| **Name:**          | `Write-ActionError.Given a valid -Message`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.005` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Write-ActionWarning

<details>
    <summary>
:heavy_check_mark: Write-ActionWarning.Given a valid -Message
    </summary>

Given a valid -Message

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Write-ActionWarning`
| **Name:**          | `Write-ActionWarning.Given a valid -Message`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0056` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Write-ActionInfo

<details>
    <summary>
:heavy_check_mark: Write-ActionInfo.Given a valid -Message
    </summary>

Given a valid -Message

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Write-ActionInfo`
| **Name:**          | `Write-ActionInfo.Given a valid -Message`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0029` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Enter-ActionOutputGroup

<details>
    <summary>
:heavy_check_mark: Enter-ActionOutputGroup.Given a valid -Name
    </summary>

Given a valid -Name

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Enter-ActionOutputGroup`
| **Name:**          | `Enter-ActionOutputGroup.Given a valid -Name`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0032` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Exit-ActionOutputGroup

<details>
    <summary>
:heavy_check_mark: Exit-ActionOutputGroup.Given everything is peachy
    </summary>

Given everything is peachy

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Exit-ActionOutputGroup`
| **Name:**          | `Exit-ActionOutputGroup.Given everything is peachy`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0025` seconds

        
</details>
    
    
###  / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Invoke-ActionWithinOutputGroup

<details>
    <summary>
:heavy_check_mark: Invoke-ActionWithinOutputGroup.Given a valid -Name and -ScriptBlock
    </summary>

Given a valid -Name and -ScriptBlock

| | |
|-|-|
| **Parent:**        | ` / Pester / C:\local\prj\bek\pwsh-github-action-tools\tests\GitHubActions_tests.ps1 / Invoke-ActionWithinOutputGroup`
| **Name:**          | `Invoke-ActionWithinOutputGroup.Given a valid -Name and -ScriptBlock`
| **Outcome:**       | `Success` :heavy_check_mark:
| **Time:**          | `0.0058` seconds

        
</details>
    
    