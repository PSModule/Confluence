function Get-ConfluenceDescendant {
    <#
        .SYNOPSIS
        List all descendants of a page (read:hierarchical-content).

        .DESCRIPTION
        Returns every descendant (child, grandchild, ...) of a page, following
        pagination automatically.

        .EXAMPLE
        ```powershell
        Get-ConfluenceDescendant -PageId '12345'
        ```

        Lists all descendants of page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Pages/Get-ConfluenceDescendant/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-descendants/
    #>
    [CmdletBinding()]
    param(
        # The ancestor page id.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId/descendants" -All -Context $Context
}
