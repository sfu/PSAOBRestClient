Function Get-AOBRestMaillistMembers {
    <#
    .SYNOPSIS
        Get Members of a Maillist from the AOB Rest Server
    .DESCRIPTION
        Get Members of a Maillist from the AOB Rest Server
    .PARAMETER Maillist
       Maillist to fetch members from
    .PARAMETER Member
        If specified, return true if Member is a member of Maillist. False otherwise. Member may be either a local username
        or a full email address
    .PARAMETER AuthToken
        Rest Server Auth Token ("art")
    .PARAMETER Uri
        The base Uri for the AOBRestServer API.
        Default: https://rest.its.sfu.ca/cgi-bin/WebObjects/AOBRestServer/rest
  
    .EXAMPLE
        Get-AOBRestUser -Maillist its-all -AuthToken 1234567890ABCDEF
        # Return members of its-all maillist
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
        [parameter(Mandatory=$true)] [string]$Maillist,
        [parameter(Mandatory=$false)][string]$Member,
        [parameter(Mandatory=$false)][string]$Uri,
        [parameter(Mandatory=$true)] [string]$AuthToken,
        [parameter(Mandatory=$false)][switch]$localOnly 
    )

    # This should support pipelining so we can handle multiple users
    # but we're not there yet.

    $Object = 'maillist/members.js'

    if ($Member)
    {
        $Body = @{
            listname = $Maillist,
            address = $Member
        }
    }
    else {
        $Body = @{
            listname = $Maillist
            }      
    }
    
    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                    "PSBoundParameters:$( $PSBoundParameters | Format-List | Out-String)")

    Try 
    {
        $Members = Get-AOBRestData -Object $Object $Uri -AuthToken $AuthToken -Body $Body
    }
    Catch 
    {
        Throw $_
    }
    
    # If passed in a member, return true/false based on membership in the list
    if ($Member)
    {
        $Members -contains $Member
    }
    elseif ($localOnly)
    {
        # If the user only wants local SFU users, push them into an array
        # Caveat: Dynamically resizing an array in PS is apparently a performance pig
        # so we'll run our for loop twice - once to calculate how many members we
        # have and once to populate
        $count=0
        $passes=0
        $localmembers=0
        do
        {
            foreach ($m in $Members)
            {
                if ($m -NotMatch "@")
                {
                    if (!$passes) 
                    { $localmembers++ }
                    else
                    { $results[$count++]=$m }
                } 
            }
            $passes++
            # This is apparently the fastest way to create an array of 'n' elements
            if ($passes -eq 1) { $results = @($null) * $localmembers }
        } until ($passes -eq 2)
        $results
    }
    else
    {
        $Members
    }

}
