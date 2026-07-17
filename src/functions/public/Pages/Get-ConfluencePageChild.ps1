#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluencePageChild {
    <#
        .SYNOPSIS
        List the direct child pages of a page (read:page).

        .DESCRIPTION
        Returns every direct child page, following pagination automatically.

        .EXAMPLE
        ```powershell
        Get-ConfluencePageChild -PageId '12345'
        ```

        Lists the direct child pages of page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Pages/Get-ConfluencePageChild/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-children/
    #>
    [OutputType([ConfluencePage])]
    [CmdletBinding()]
    param(
        # The parent page ID.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $PageId,

        # The context to use: an object, a context name, or $null for the default.
        [Parameter()]
        [object] $Context
    )

    foreach ($page in @(Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId/children" -All -Context $Context)) {
        ConvertTo-ConfluenceType -InputObject $page -TypeName 'ConfluencePage'
    }
}
