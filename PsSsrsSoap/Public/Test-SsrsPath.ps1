<#
.SYNOPSIS
Tests the existence of a folder or other SSRS object.

.PARAMETER Server
Name or IP address of SSRS server.

.PARAMETER Path
Folder or object path.

.EXAMPLE
Test-SsrsPath -Server reportserver.domain.tld -Path '/path'

Tests the existence of a folder.

.EXAMPLE
Test-SsrsPath -Server reportserver.domain.tld -Path '/path/to/report'

Tests the existence of a report.

.LINK
https://docs.microsoft.com/en-us/dotnet/api/reportservice2010.reportingservice2010.getitemtype?view=sqlserver-2016
#>
function Test-SsrsPath
{
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory)]
        [string]$Server,

        [Parameter(Position=1,Mandatory,ValueFromPipeline)]
        [string]$Path        
    )
    
    begin
    {
        $Uri = "https://$Server/ReportServer/ReportService2010.asmx?wsdl"
        $Proxy = New-RsWebServiceProxy -ApiVersion 2010 -ReportServerUri $Uri
    }

    process
    {
        Write-Debug "Server: $Server"
        Write-Debug "Path: $Path"

        try
        {
            # remove trailing '/' if not root directory
            $Path = if ($Path.EndsWith('/') -and $Path.Length -gt 1) { $Path.Substring(0,$Path.Length-1) } else { $Path }

            Write-Verbose "Testing $Path..."

            # test for presence of parent
            $ItemType = $Proxy.GetItemType($Path)
            Write-Debug "ItemType: $ItemType"

            if ( $null -eq $ItemType -or $ItemType -eq 'Unknown' ){ $false }
            else { $true }
        }
        catch
        {
            Write-Error $_.Exception.Message
        }
    }

    end
    {
        # release resources
        $Proxy = $null
    }
}