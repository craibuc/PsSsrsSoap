<#
.SYNOPSIS
Publishes an RDL document (XML) to reporting services.

.PARAMETER Server
The server's IP or name.

.PARAMETER Folder
Folder that will contain the report in SSRS.

.PARAMETER InputObject
RDL document to publish.

.PARAMETER Property
Property array to include

.PARAMETER Force
If the report exists, overwrite it.

.EXAMPLE
Set-SsrsDefinition -Server reportserver.domain.tld -Folder '/foo/bar/baz' -InputObject ~/Documents/report.rdl

Publish ~/Documents/report.rdl to the /foo/bar/baz folder on reportserver.domain.tld

.EXAMPLE
Get-ChildItem -Filter *.rdl | Set-SsrsDefinition -Server reportserver.domain.tld -Folder '/foo/bar/baz'

Publish all RDL files in ~/Documents to the /foo/bar/baz folder on reportserver.domain.tld

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
        [string]$Folder,

        [Parameter(Position=2,Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$InputObject,

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
        foreach ($FileInfo in $InputObject)
        {
            Write-Verbose "Processing: $($FileInfo.Name)"

            # if folder doesn't exist, create it
            $ItemType = $Proxy.GetItemType($Folder)

            if ( $null -eq $ItemType -or $ItemType -eq 'Unknown' )
            {
                New-SsrsFolder -Server $Server -Path $Folder -WhatIf:$WhatIfPreference
            }

            if ($PSCmdlet.ShouldProcess($FileInfo.BaseName, "CreateCatalogItem()")) 
            {
                try
                {
                    # create XML document; populate w/ RDL
                    $RDL = New-Object System.Xml.XmlDocument
                    $RDL.Load($FileInfo.FullName)

                    # XML to byte[]
                    [byte[]]$bytes = [Text.Encoding]::Default.GetBytes($RDL.OuterXml)

                    $Warning = $null

                    # publish report
                    $Proxy.CreateCatalogItem('Report', $FileInfo.BaseName, $Folder, $Force, $bytes, $null, [ref] $Warning) | Out-Null

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
                    $RDL = $null
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
