<#
.SYNOPSIS
Creates a folder in reporting services.

.PARAMETER Server
The server's IP or name.

.PARAMETER Path
Path to report in SSRS.

.PARAMETER Parent
Create parent directories as needed.

.EXAMPLE
New-SsrsFolder -Server reportserver.domain.tld -Path '/one/two/three' -Parent

Create a new folder

.LINK
https://docs.microsoft.com/en-us/dotnet/api/reportservice2010.reportingservice2010.createfolder?view=sqlserver-2016

#>
function New-SsrsFolder
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position=0,Mandatory)]
        [string]$Server,

        [Parameter(Position=1,Mandatory)]
        [string]$Path,

        [Parameter(Position=2)]
        [switch]$Parent
    )
    
    begin
    {
        $Uri = "https://$Server/ReportServer/ReportService2010.asmx?wsdl"
        $Proxy = New-RsWebServiceProxy -ApiVersion 2010 -ReportServerUri $Uri
    }

    process
    {

        try
        {

            # /one/two/three
            # split into segments
            $Segment = $Path -split '/'

            # for each segment
            for ($i = 0; $i -lt $Segment.Count; $i++) 
            {
                $P = if ( $i -eq 0 )
                {
                    '/'
                }
                else
                {
                    # add to prior segment if the is one
                }

                # test the path
                # if it doesn't exist, create folder

            }


            # $Parent = (Split-Path $Path -Parent).Replace('\','/')
            # $Name = Split-Path $Path -Leaf

            # test for presence of parent
            # $ItemType = $Proxy.GetItemType($Parent)
            
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