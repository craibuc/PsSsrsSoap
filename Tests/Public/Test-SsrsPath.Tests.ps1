BeforeAll {
    
    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $ModuleName = Split-Path $ProjectDirectory -Leaf

    $PublicPath = Join-Path $ProjectDirectory "/$ModuleName/Public/"

    $SUT = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'

    . (Join-Path $PublicPath $SUT)

}

Describe "Test-SsrsPath" {

    Context "Parameter validation" {

        BeforeAll {
            $Command = Get-Command 'Test-SsrsPath'
        } 

        @{Name='Server'; Type=[string]; Mandatory=$true; Position=0; ValueFromPipeline=$false},
        @{Name='Path'; Type=[string]; Mandatory=$true; Position=1; ValueFromPipeline=$true} | ForEach-Object {

            $Parameter = $_

            Context "$($Parameter.Name)" {
                
                It "is a <Type>" -TestCases $Parameter {
                    param ($Name, $Type)
                    $Command | Should -HaveParameter $Name -Type $Type
                }

                It "is mandatory <Mandatory>" -TestCases $Parameter {
                    param ($Name, $Mandatory)
                    $Command | Should -HaveParameter $Name -Mandatory $Mandatory
                }

                It "has position <Position>" -TestCases $Parameter {
                    param ($Name, $Position)
                    $Command.Parameters[$Name].Attributes.Position | Should -Be $Position
                }

                It "accepts <ValueFromPipeline>" -TestCases $Parameter {
                    param ($Name, $ValueFromPipeline)
                    $Command.Parameters[$Name].Attributes.ValueFromPipeline | Should -Be $ValueFromPipeline
                }

            } # /Content

        } # /ForEach-Object

    } # /Content

    Context 'Usage' -Skip {

        BeforeAll {
            # Mock New-RsWebServiceProxy
            # $MockObject = New-MockObject -Type 'ReportService2010'
            # $MockObject | Add-Member -Type NoteProperty -Name 'existingproperty' -Value 'foo' -Force
            # $MockObject | Add-Member -Type Method -Name GetItemType -Value { $true }
            # -Type ScriptMethod -Name 'existingmethod' -Value { whatever } -Force
            # GetItemType
            # $obj.GetType().FullName
                # System.Diagnostics.Process
        }

        Context "when a valid path is supplied'" {
            BeforeEach {
                
                # Mock GetItemType {
                #     $MockObject = New-MockObject -Type 'ReportService2010'
                #     $MockObject | Add-Member -Type Method -Name GetItemType -Value { $true }
                #     $MockObject
                # }

                Mock New-RsWebServiceProxy {
                    # $MockObject = New-MockObject -Type 'ReportService2010'
                    # $MockObject | Add-Member -Type Method -Name GetItemType -Value { $true }
                }
            }

            It 'returns true' {

                Test-SsrsPath -Server '' -Path ''

                # Should -Invoke GetItemType
                # Assert-MockCalled -
                Should -Invoke GetItemType -ParameterFilter {
                    $DriverID -eq $BambooHrEmployee.employeeNumber
                }
                # Assert-MockCalled Start-Sleep -Times 1 -Exactly -ParameterFilter {
                #     Write-Debug "Seconds: $Seconds"
                #     Write-Debug "BatchDelay: $($Settings.SmtpSettings.BatchDelay)"
                #     $Seconds -eq $Settings.SmtpSettings.BatchDelay
                # }
            }
        }

        Context "when an invalid path is supplied" {
            # BeforeAll {
            #     $MockObject = New-MockObject -Type 'ReportService2010'
            #     $MockObject | Add-Member -Type Method -Name GetItemType -Value { $false }
            # }

            It 'returns false' {
                $false | Should -Be $true
            }
        }

    } # /Content

} # /Describe
