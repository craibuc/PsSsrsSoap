BeforeAll {
    
    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $ModuleName = Split-Path $ProjectDirectory -Leaf

    $PublicPath = Join-Path $ProjectDirectory "/$ModuleName/Public/"

    $SUT = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'

    . (Join-Path $PublicPath $SUT)

}

Describe "Get-SsrsDefinition" {

    Context "Parameter validation" {

        BeforeAll {
            $Command = Get-Command 'Get-SsrsDefinition'
        } 

        @{Name = 'Server';Type = [string];Mandatory=$true;Position=0},
        @{Name = 'Path';Type = [string];Mandatory=$true;Position=1;ValueFromPipeline=$rue} | ForEach-Object {

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
                    # $Command | Should -HaveParameter $ParameterName
                }

            } # /Context

        } # /ForEach-Object

    } # /Context

} # /Describe
