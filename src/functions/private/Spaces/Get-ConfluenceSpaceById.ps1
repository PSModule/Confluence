function Get-ConfluenceSpaceByIdEndpoint {
    <#
        .SYNOPSIS
        Get a space by ID from the Confluence v2 spaces endpoint.

        .DESCRIPTION
        Calls `/wiki/api/v2/spaces/{id}` for one exact space identifier.

        .EXAMPLE
        Get-ConfluenceSpaceByIdEndpoint -Id '123456'

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
        # The exact Confluence space ID.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        # The context to use: an object, a context name, or $null for the default.
        [Parameter()]
        [object] $Context
    )

    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/spaces/$Id" -Context $Context
}
