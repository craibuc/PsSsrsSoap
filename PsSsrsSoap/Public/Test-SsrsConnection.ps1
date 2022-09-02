<#
.SYNOPSIS
Tests the connection to a SSRS server.

.PARAMETER Server
Name or IP address of SSRS server.

.PARAMETER UseInsecure
Uses HTTP instead of HTTPS.

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

        [Parameter()]
        [switch]$UseInsecure
    )

    begin {}
    process {
    
        $Schema = if ($UseInsecure.IsPresent) {'HTTP'} else {'HTTPS'}
        $Uri = "$Schema`://$Server/ReportServer/ReportService2010.asmx?wsdl"
    
        try {
            Write-Verbose "Testing $Uri..."
            New-RsWebServiceProxy -ApiVersion 2010 -ReportServerUri $Uri | Out-Null
            $true
        }
        catch {
            Write-Host $_.Exception.Message -ForegroundColor Red
            $false
        }
    
    }
    end {}
}
