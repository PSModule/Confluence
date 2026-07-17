#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluencePageVersion {
    <#
        .SYNOPSIS
        List the version history of a page (read:page).

        .DESCRIPTION
        Returns every version entry for a page, newest first, following pagination.

        .EXAMPLE
        ```powershell
        Get-ConfluencePageVersion -PageId '12345'
        ```

        Lists the version history of page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Pages/Get-ConfluencePageVersion/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-version/
    #>
    [OutputType([ConfluencePageVersion])]
    [CmdletBinding()]
    param(
        # The page ID.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $PageId,

        # The context to use: an object, a context name, or $null for the default.
        [Parameter()]
        [object] $Context
    )

    foreach ($version in @(Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId/versions" -All -Context $Context)) {
        ConvertTo-ConfluenceType -InputObject $version -TypeName 'ConfluencePageVersion'
    }
}
