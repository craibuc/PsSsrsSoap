<#PSScriptInfo
.VERSION 0.1.1
.GUID 6bd191b1-6882-4db8-a6ad-8c04bb79d318
.AUTHOR Craig Buchanan
.COMPANYNAME cogniza
.COPYRIGHT 
.TAGS ssrs, rdl
.LICENSEURI 
.PROJECTURI 
.ICONURI 
.EXTERNALMODULEDEPENDENCIES ReportingServicesTools
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES

#>

<#
.SYNOPSIS
Save RDL files to local directory.

.DESCRIPTION
Save RDL files to local directory.

.PARAMETER Server
SSRS server IP or address.

.PARAMETER Folder
SSRS folder to start processing.

.PARAMETER Path
Location to save RDL files.

.PARAMETER TypeName
Type of object to save.

.PARAMETER UseInsecure
Forces the use of HTTP.

.EXAMPLE
./Save-SsrsRdl.ps1 -Server reporting.domain.tld -Folder / -ItemType report -Path ~/Desktop

Save all RDL documents to a folder on the Desktop.

.EXAMPLE
./Save-SsrsRdl.ps1 -Server reporting.domain.tld -Folder / -ItemType report -Path ~/Desktop -UseInsecure

Use HTTP.
#>

#Requires -PSEdition Desktop
#Requires -Modules ReportingServicesTools

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [string]$Server,

    [Parameter(Mandatory)]
    [string]$Folder,

    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter()]
    [ValidateSet('DataSource','Report')]
    [string[]]$TypeName = ('DataSource','Report'),

    [Parameter()]
    [switch]$UseInsecure
)

try
{
    $Schema = if ($UseInsecure.IsPresent) {'HTTP'} else {'HTTPS'}
    $Uri = "$Schema`://$Server/ReportServer/ReportService2010.asmx?wsdl"
    Write-Debug "Uri: $Uri"

    $Proxy = New-RsWebServiceProxy -ReportServerUri $Uri

    $Path = Resolve-Path -Path $Path

    Get-RsFolderContent -ReportServerUri $Uri -RsFolder $Folder -Recurse | Where-Object { $_.TypeName -in $TypeName } | ForEach-Object {
        
        try 
        {
            Write-Verbose ("Processing: {0}" -f $_.Path)

            # populate byte array with data
            [byte[]] $RDL = $null;
            $RDL = $Proxy.GetItemDefinition($_.Path)
            
            # create stream
            [System.IO.MemoryStream] $memStream = New-Object System.IO.MemoryStream(@(,$RDL))
    
            # create XML document
            $rdlFile = New-Object System.Xml.XmlDocument
            $rdlFile.Load($memStream)
    
            # target location
            $ext = if ( $_.TypeName -eq 'DataSource') {'xml'} else {'rdl'}
            $OutPath = Join-Path $Path ("{0}{1}.{2}" -f $Server, $_.Path, $ext)
            Write-Debug "OutPath: $OutPath"
    
            # containing folder
            $Directory = Split-Path $OutPath -Parent
            Write-Debug "Directory: $Directory"
    
            # create containing folder
            New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    
            if ( $PSCmdlet.ShouldProcess($OutPath,'Save') )
            {
                # save RDL
                $rdlFile.Save($OutPath)
            }
    
            # manage memory
            $memStream.Dispose()
            $memStream = $null
        }
        catch 
        {
            Write-Host "ERROR: $( $_.Exception.Message )" -ForegroundColor Red
        }

    }

}
catch 
{
    Write-Host "CRITICAL: $( $_.Exception.Message )" -ForegroundColor Red
}
finally
{
    $Proxy = $null
}