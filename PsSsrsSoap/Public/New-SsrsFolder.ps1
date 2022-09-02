<#
.SYNOPSIS
Creates a folder in reporting services.

.PARAMETER Server
The server's IP or name.

.PARAMETER Path
Path to report in SSRS.

.PARAMETER UseInsecure
Uses HTTP instead of HTTPS.

.EXAMPLE
New-SsrsFolder -Server reportserver.domain.tld -Path '/one/two/three'

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

        try
        {
            # normalize
            # \one\two\three --> /one/two/three
            $Path = $Path.Replace('\','/')

            # split into segments
            # /one/two/three --> [,one,two,three]
            $Segment = $Path -split '/'

            # for each segment
            for ($i = 1; $i -lt $Segment.Count; $i++) 
            {
                $CurrentPath = '/' + ($Segment[1..$i] -join '/')
                Write-Debug ("CurrentPath: $CurrentPath")

                $Folder,$Parent = 
                if ( $i -eq 1 )
                {
                    $Segment[$i],'/'
                }
                else
                {
                    $Segment[$i],( '/' + ($Segment[1..($i-1)] -join '/') )
                }

                Write-Debug ("Folder: {0} Parent:{1}" -f $Folder, $Parent)

                # if folder doesn't exist, create it
                if ( (Test-SsrsPath -Server $Server -Path $CurrentPath -UseInsecure:$UseInsecure) -eq $false ) 
                {
                    if ($PSCmdlet.ShouldProcess($CurrentPath, "CreateFolder()")) 
                    {
                        $Proxy.CreateFolder($Folder, $Parent, $null) | Out-Null
                    }

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