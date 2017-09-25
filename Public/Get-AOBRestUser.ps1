Function Get-AOBRestUser {
    <#
    .SYNOPSIS
        Get user properties from the AOB Rest Server
    .DESCRIPTION
        Get user properties from the AOB Rest Server
    .PARAMETER Username
        Computing ID or SFUID of Username to fetch
    .PARAMETER AuthToken
        Rest Server Auth Token ("art")
    .PARAMETER Uri
        The base Uri for the AOBRestServer API.
        Default: https://rest.its.sfu.ca/cgi-bin/WebObjects/AOBRestServer/rest
  
    .EXAMPLE
        Get-AOBRestUser -Username kipling -AuthToken 1234567890ABCDEF
        # Return properties for user 'kipling'
    .EXAMPLE
        Get-AOBRestUser -Username 555000001 -AuthToken 1234567890ABCDEF
        # Return properties of the user whose SFUID is 555000001
    .FUNCTIONALITY
        AOBRestServer
    .LINK
        https://confluence.its.sfu.ca/atl-conf/display/IDAM/REST+Server
    .LINK
        https://github.com/sfu/PSAOBRestClient
    .LINK
        Get-AOBRestData
    #>


    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)] [string]$Username,
        [parameter(Mandatory=$false)][string]$Uri,
        [parameter(Mandatory=$true)] [string]$AuthToken  
    )

    Begin 
    {
        $Object = 'datastore2/global/userBio.js'
    }

    Process 
    {
        $Body = @{
                username = $Username
                }      

        Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                        "PSBoundParameters:$( $PSBoundParameters | Format-List | Out-String)")

        Try 
        {
            if ($Uri)
            {
                $User = Get-AOBRestData -Object $Object -Uri $Uri -AuthToken $AuthToken -Body $Body
            }
            else 
            {
                $User = Get-AOBRestData -Object $Object -AuthToken $AuthToken -Body $Body
            }
        }
        Catch 
        {
            # Write a "user not found" error to STDERR and continue on
            if ($_.toString() -Match "There is no account")
            {
                Write-Error "No such user: $Username"
                Write-Error $_
            }
            # All other errors, abort the pipeline
            else
            {
                Throw $_
            }
        }
        $User
    }

}
