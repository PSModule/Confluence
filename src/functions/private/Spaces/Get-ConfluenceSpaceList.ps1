function Get-ConfluenceSpaceListEndpoint {
    <#
        .SYNOPSIS
        List spaces from the Confluence v2 spaces endpoint.

        .DESCRIPTION
        Calls `/wiki/api/v2/spaces` and aggregates all result pages.

        .EXAMPLE
        Get-ConfluenceSpaceListEndpoint

        .INPUTS
        None.

        .OUTPUTS
        System.Object

        .NOTES
        Private helper used by Get-ConfluenceSpace.

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-space/
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        # The context to use: an object, a context name, or $null for the default.
        [Parameter()]
        [object] $Context
    )

    Invoke-ConfluenceRestMethod -ApiVersion 'v2' -ApiEndpoint 'spaces' -All -Context $Context
}
