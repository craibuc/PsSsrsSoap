<#
.SYNOPSIS
Tests the connection to a SSRS server.

.PARAMETER Server
Name or IP address of SSRS server.

.PARAMETER Schema
HTTP or HTTPS

.EXAMPLE
'server01','server02' | Test-SsrsConnection -Verbose

Tests the connections to server01 and server02 over HTTPS

.EXAMPLE
'server01','server02' | Test-SsrsConnection -Schema HTTP -Verbose

Tests the connections to server01 and server02 over HTTP
#>
function Test-SsrsConnection
{
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Server,

        [ValidateSet('http','https')]
        [string]$Schema='https'
    )

    begin {}
    process {
    
        $Uri = "$Schema`://$Server/ReportServer/ReportService2010.asmx?wsdl"
    
        try {
            Write-Verbose "Testing $Uri..."
            $Proxy = New-RsWebServiceProxy -ApiVersion 2010 -ReportServerUri $Uri
            $true
        }
        catch {
            Write-Host $_.Exception.Message -ForegroundColor Red
            $false
        }
        finally { $Proxy = $null }
    
    }
    end {}
}
