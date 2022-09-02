<#PSScriptInfo
.VERSION 0.0.0
.GUID 6406dc74-a49d-471b-9a8d-c4b9aeb93a4b
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
Extracts the DataSet information from the specified path.

.DESCRIPTION
Extracts the DataSet information from the specified path.

.PARAMETER Path
Location of RDL files.

.PARAMETER Path
Location of RDL files.

.EXAMPLE
./Get-RdlDataSet.ps1 -Path ~\Documents\MyReports

Extracts the (StoredProcedure) DataSet information from the ~\Documents\MyReports.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter()]
    [ValidateSet('StoredProcedure')]
    [string]$CommandType = 'StoredProcedure'
)

Get-ChildItem -Path $Path -File -Recurse -Filter '*.rdl' | ForEach-Object {

    $Item = $_

    $Xml = New-Object System.Xml.XmlDocument
    $Xml.Load($Item.FullName)
    
    $Xml.Report.DataSets.DataSet.Query | 
        Where-Object {$_.CommandType -eq 'StoreProcedure' } | 
        Select-Object @{Name='Path';Expression={$Item.DirectoryName}}, @{Name='ReportName';Expression={$Item.Name}}, @{Name='DataSet';Expression={ $_.ParentNode.Name }}, DataSourceName, CommandType, CommandText

} | ConvertTo-Csv -NoTypeInformation | Out-File ~/Desktop/DataSets.csv
