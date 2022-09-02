<#PSScriptInfo
.VERSION 0.1.0
.GUID 1b031bf8-5d66-49df-a2cf-2e39d94a5413
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

.PARAMETER Path
Location to save RDL files.

.PARAMETER UseInsecure
Uses HTTP instead of HTTPS.

.EXAMPLE
./Publish-SsrsRdl.ps1 -Server reporting.domain.tld -Path ~\Documents\MyReports

Publish all of the RDL files in ~\Documents\MyReports to reporting.domain.tld
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Server,

    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter()]
    [switch]$UseInsecure
)

#Requires -PSEdition Desktop
#Requires -Modules PsSsrsSoap

Write-Debug "Server: $Server"
Write-Debug "Path: $Path"

$ResolvedPath = Resolve-Path $Path
Write-Debug "ResolvedPath: $ResolvedPath"

try 
{
    Get-ChildItem -Path $ResolvedPath -File -Filter *.rdl -Recurse | ForEach-Object {

        # extract the remote folder location from the RDL-file's path
        $RemoteDirectory = $_.DirectoryName.Substring($_.DirectoryName.indexof($Server)+$Server.length).Replace('\','/')
        Write-Debug "RemoteDirectory $RemoteDirectory"
    
        # publish the file to the server
        $_ | Set-SsrsDefinition -Server $Server -Folder $RemoteDirectory -UseInsecure:$UseInsecure -WhatIf:$WhatIfPreference -Verbose:$VerbosePreference

    }

}
catch 
{
    Write-Host "ERROR: $( $_.Exception.Message )" -ForegroundColor Red
}
