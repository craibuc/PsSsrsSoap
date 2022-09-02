<#
.SYNOPSIS
Gets the properties of the specified object.

.PARAMETER Server
Name or IP address of SSRS server.

.PARAMETER Path
Report path

.PARAMETER UseInsecure
Uses HTTP instead of HTTPS.

.EXAMPLE
Get-SsrsProperty -Server reportserver.domain.tld -Path '/path/to/report'

Get the properties collection for the specified object.

.LINK
https://docs.microsoft.com/en-us/dotnet/api/reportservice2010.reportingservice2010.getproperties?view=sqlserver-2016
#>

function Get-SsrsProperty
{
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory)]
        [string]$Server,

        [Parameter(Position=1,Mandatory,ValueFromPipeline)]
        [string]$Path,

        [Parameter()]
        [switch]$UseInsecure
    )
    
    begin 
    {
        $Schema = if ($UseInsecure.IsPresent) {'HTTP'} else {'HTTPS'}
        $Uri = "$Schema`://$Server/ReportServer/ReportService2010.asmx?wsdl"
        $Proxy = New-RsWebServiceProxy -ApiVersion 2010 -ReportServerUri $Uri
    }
    
    process
    {
        foreach ($P in $Path)
        {
            Write-Verbose "Processing: $P"

            $Properties = $null
            $Proxy.GetProperties($P, $Properties)
            $Properties
        }
    }
    
    end 
    {
        $Proxy = $null
    }

}