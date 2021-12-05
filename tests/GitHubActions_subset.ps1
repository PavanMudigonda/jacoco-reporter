
Import-Module Pester
Import-Module GitHubActions

Set-Variable -Scope Script -Option Constant -Name EOL -Value ([System.Environment]::NewLine) -ErrorAction Ignore

Describe 'Set-ActionVariable' {
    $testCases = @(
        @{ Name = 'varName1'  ; Value = 'varValue1' }
        @{ Name = 'var name 2'; Value = 'var value 2' }
        @{ Name = 'var,name;3'; Value = 'var,value;3'
            Expected = "::set-env name=var%2Cname%3B3::var,value;3BAD$EOL" }
    )
    It 'Given valid -Name and -Value, and -SkipLocal' -TestCases $testCases {
        param($Name, $Value, $Expected)

        if (-not $Expected) {
            $Expected = "::set-env name=$($Name)::$($Value)$EOL"
        }
        
        $output = Set-ActionVariable $Name $Value -SkipLocal
        $output | Should -Be $Expected
        [System.Environment]::GetEnvironmentVariable($Name) | Should -BeNullOrEmpty
    }
    It 'Given valid -Name and -Value, and NOT -SkipLocal' -TestCases $testCases {
        param($Name, $Value, $Expected)

        if (-not $Expected) {
            $Expected = "::set-env name=$($Name)::$($Value)$EOL"
        }
        
        Set-ActionVariable $Name $Value | Should -Be $Expected
        [System.Environment]::GetEnvironmentVariable($Name) | Should -Be $Value
    }
}

Describe 'Add-ActionSecretMask' {
    It 'Given a valid -Secret' {
        $secret = 'f00B@r!'
        Add-ActionSecretMask $secret | Should -Be "::add-mask::$($secret)$EOL"
    }
}

Describe 'Write-ActionDebug' -Skip {
    It 'Given a valid -Message' {
        $output = Write-ActionDebug 'This is a sample message'
        $output | Should -Be "::debug::This is a sample message$EOL"
    }
}
