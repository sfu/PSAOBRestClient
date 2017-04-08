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
        [parameter(Mandatory=$true)] [string]$Username,
        [parameter(Mandatory=$false)][string]$Uri = 'https://rest.its.sfu.ca/cgi-bin/WebObjects/AOBRestServer.woa/rest',
        [parameter(Mandatory=$true)] [string]$AuthToken  
    )

    # This should support pipelining so we can handle multiple users
    # but we're not there yet.

    $Object = 'global/userBio.js'
    $Body = @{
            username = $Username
            }


    Try 
    {
        $User = Get-AOBRestData -Object $Object -AuthToken $AuthToken -Body $Body
    }
    Catch 
    {
        Throw $_
    }

}
