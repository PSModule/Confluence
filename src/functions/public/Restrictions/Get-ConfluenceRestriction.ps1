#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluenceRestriction {
    <#
        .SYNOPSIS
        Get the content restrictions on a page (read:content-details).

        .DESCRIPTION
        Returns the read/update restrictions applied to a page. Reading
        restrictions requires read:content-details; the read:content.restriction
        scope only covers the narrow byOperation/{op}/user|group status checks.
        Content restrictions are part of the v1 content API (see the link).

        .EXAMPLE
        ```powershell
        Get-ConfluenceRestriction -PageId '12345'
        ```

        Gets the read/update restrictions on page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Restrictions/Get-ConfluenceRestriction/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v1/api-group-content-restrictions/
    #>
    [CmdletBinding()]
    param(
        # The page id.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    # Content restrictions live on the v1 content API; there is no equivalent v2
    # endpoint (a v2 '/pages/{id}/restrictions' path is rejected with a scope
    # check). The v1 endpoint returns the read/update operations in 'results'.
    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/rest/api/content/$PageId/restriction" -All -Context $Context
}
