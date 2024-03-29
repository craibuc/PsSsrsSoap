<#
.SYNOPSIS
Retrieves an RDL document (XML) from reporting services.

.PARAMETER Server
The server's IP or name.

.PARAMETER Path
Path to report in SSRS.

.PARAMETER UseInsecure
Uses HTTP instead of HTTPS.

.EXAMPLE
$RDL = Get-SsrsDefinition -Server reportserver.domain.tld -Path '/Radiology/MyReport'
$RDL.Save('~\Desktop\Radiology\MyReport.rdl')

Save the report's RDL to a local file.

.LINK
https://docs.microsoft.com/en-us/dotnet/api/reportservice2010.reportingservice2010.getitemdefinition?view=sqlserver-2016

#>

function Get-SsrsDefinition
{
    [CmdletBinding(SupportsShouldProcess)]
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

            try
            {
                if ($PSCmdlet.ShouldProcess($P, "GetItemDefinition()")) 
                {
                    [byte[]]$bytes = $null;
                    $bytes = $Proxy.GetItemDefinition($P)
                    
                    # $Defintion = [System.Text.Encoding]::UTF8.GetString($bytes)
                    # $RDL = New-Object System.Xml.XmlDocument
                    # $RDL.LoadXml($Defintion)

                    [System.IO.MemoryStream]$MemoryStream = New-Object System.IO.MemoryStream(@(,$bytes));
        
                    $Defintion = New-Object System.Xml.XmlDocument
                    $Defintion.Load($MemoryStream)
                    $Defintion    
                }
            }
            catch
            {
                Write-Error $_.Exception.Message
            }
            finally
            {
                # release resources
                if ($MemoryStream) { $MemoryStream.Dispose() }
            }

        }
    }
    
    end
    {
        # release resources
        $Proxy = $null
    }
}
