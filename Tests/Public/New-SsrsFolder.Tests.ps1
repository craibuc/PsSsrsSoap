BeforeAll {
    
    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $ModuleName = Split-Path $ProjectDirectory -Leaf

    $PublicPath = Join-Path $ProjectDirectory "/$ModuleName/Public/"

    $SUT = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'

    . (Join-Path $PublicPath $SUT)

}

Describe "New-SsrsFolder" {

    Context "Parameter validation" {

        BeforeAll {
            $Command = Get-Command 'New-SsrsFolder'
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

                # It "accepts <ValueFromPipeline>" -TestCases $Parameter {
                #     param ($Name, $ValueFromPipeline)
                #     $Command.Parameters[$Name].Attributes.ValueFromPipeline | Should -Be $ValueFromPipeline
                # }

            } # /Content

        } # /ForEach-Object

    } # /Content

    Context 'Usage' {

        Context "when a valid path is supplied'" {

            BeforeEach {
                # arrange
                $Server = 'reportingservices.domain.tld'

                Mock New-RsWebServiceProxy

                # act
                New-SsrsFolder -Server $Server -Path '/foo/bar'
            }

            It 'uses the correct settings' {
                # assert
                Should -Invoke New-RsWebServiceProxy -ParameterFilter {
                    $Uri -like "*$Server*"
                }
            }

        }

    }

} # /Describe