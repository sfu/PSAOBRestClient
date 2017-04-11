Function Get-AOBRestData {
    <#
    .SYNOPSIS
        Get data from the AOB Rest Server
    .DESCRIPTION
        Get data from the AOB Rest Server
    .PARAMETER Object
        Rest Endpoint to query. Accepts multiple parts.
        Example: 'global/userBio' or 'maillist/members'
    .PARAMETER AuthToken
        Rest Server Auth Token ("art")
    .PARAMETER Uri
        The base Uri for the AOBRestServer API.
        Default: https://rest.its.sfu.ca/cgi-bin/WebObjects/AOBRestServer/rest
    .PARAMETER Body
        Hash table with query options for specific object
        Example for userBio:
            -Body @{
                username  =  'kipling'
            }
    .EXAMPLE
        Get-AOBRestData -Object global/userBio -AuthToken 1234567890ABCDEF -Body @{username='kipling'}
        # Return properties for user 'kipling'
    .EXAMPLE
        Get-AOBRestData -Object maillist/members -AuthToken 1234567890ABCDEF -Body @{listname='test-123'}
        # Get the members of the 'test-123' mail list
    .FUNCTIONALITY
        AOBRestServer
    .LINK
        https://confluence.its.sfu.ca/atl-conf/display/IDAM/REST+Server
    .LINK
        https://github.com/sfu/PSAOBRestClient
    .LINK
        Get-AOBRestUser
    .LINK
        Get-AOBRestMembersOfMaillist
    #>


    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)] [string]$Object,
        [parameter(Mandatory=$false)][string]$Uri = 'https://rest.its.sfu.ca/cgi-bin/WebObjects/AOBRestServer.woa/rest',
        [parameter(Mandatory=$true)] [string]$AuthToken,  
        [parameter(Mandatory=$false)][Hashtable]$Body
    )

    #Build up URI
    $BaseUri = Join-Parts -Separator "/" -Parts $Uri, $Object

    #Build Headers
    $Headers = @{
         Authorization = "Bearer "+$AuthToken
    }

    $Body.Add("art",$AuthToken)

    #Build up Invoke-RestMethod
    $IRMParams = @{
        ErrorAction = 'Stop'
        Uri = $BaseUri
        Method = 'Get'
        Headers = $Headers
        Body = $Body
    }

    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                    "PSBoundParameters:$( $PSBoundParameters | Format-List | Out-String)" +
                    "Invoke-RestMethod parameters:`n$($IRMParams | Format-List | Out-String)")

    Try
    {
     
        write-debug "Final $($IRMParams | Out-string) Body $($IRMParams.Body | Out-String)"

        #We might want to track the HTTP status code to verify success for non-gets...
        $TempResult = Invoke-RestMethod @IRMParams

        #TODO: What does TempResult look like? Is there an HTTP return code we can examine?

        Write-Debug "Raw:`n$($TempResult | Out-String)"

    }
    Catch
    {
        Throw $_
    }

    if($TempResult.PSObject.Properties.Name -contains 'items')
    {
        $TempResult.items
    }
    else # what is going on!
    {
        $TempResult
    }
}