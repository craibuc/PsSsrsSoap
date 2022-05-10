<#
.SYNOPSIS
Publishes an RDL document (XML) to reporting services.

.PARAMETER Server
The server's IP or name.

.PARAMETER Path
Path to report in SSRS.

.PARAMETER InputObject
RDL document to publish.

.PARAMETER Property
Property array to include

.PARAMETER Force
If the report exists, overwrite it.

.EXAMPLE

.LINK
https://docs.microsoft.com/en-us/dotnet/api/reportservice2010.reportingservice2010.createcatalogitem?view=sqlserver-2016

#>

function Set-SsrsDefinition
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position=0,Mandatory)]
        [string]$Server,

        [Parameter(Position=1,Mandatory)]
        [string]$Path,

        [Parameter(Position=2,Mandatory,ValueFromPipeline)]
        [System.Xml.XmlDocument]$InputObject,

        [Parameter(Position=3)]
        [object]$Property,

        [Parameter(Position=4)]
        [switch]$Force
    )
    
    begin
    {
        $Uri = "https://$Server/ReportServer/ReportService2010.asmx?wsdl"
        $Proxy = New-RsWebServiceProxy -ApiVersion 2010 -ReportServerUri $Uri
    }
    
    process
    {
        foreach ($P in $Path)
        {
            Write-Verbose "Processing: $P"

            # split path into name and parent
            # /path/to/report --> /path/to and report
            # /report --> / and report

            $Parent = (Split-Path $Path -Parent).Replace('\','/')
            $Name = Split-Path $Path -Leaf

            # test for presence of parent
            $ItemType = $Proxy.GetItemType($Parent)
            if ( $null -eq $ItemType -or $ItemType -eq 'Unknown' )
            {
                Write-Verbose "Creating folder '$Parent'..."

                $Grandparent = (Split-Path $Parent -Parent).Replace('\','/')
                $Leaf = Split-Path $Parent -Leaf

                if ($PSCmdlet.ShouldProcess($Parent, "CreateFolder()")) 
                {
                    $Proxy.CreateFolder($Leaf, $Grandparent, $null) | Out-Null
                }
            }

            if ($PSCmdlet.ShouldProcess($Path, "CreateCatalogItem()")) 
            {
                try
                {
                    # XML to byte[]
                    [byte[]]$bytes = [Text.Encoding]::Default.GetBytes($InputObject.OuterXml)

                    # [System.IO.MemoryStream]$MemoryStream = New-Object System.IO.MemoryStream
                    # $InputObject.Save($MemoryStream)
                    # [byte[]]$bytes = $MemoryStream.ToArray()

                    $Warning = $null
                    $Proxy.CreateCatalogItem('Report', $Name, $Parent, $Force, $bytes, $null, [ref] $Warning) | Out-Null

                    foreach ($W in $Warning)  
                    {
                        Write-Warning $W.Message
                    }
                }
                catch
                {
                    Write-Error $_.Exception.Message
                }
                finally
                {
                    # release resources
                    # if ($MemoryStream) { $MemoryStream.Dispose() }
                }
            }
        }
    }
    
    end
    {
        # release resources
        $Proxy = $null
    }
}
