function Get-ConfluenceLabel {
    <#
        .SYNOPSIS
        List the labels on a page (read:page).

        .DESCRIPTION
        Returns every label on the page, following pagination. In v2 a page's
        labels are read under the page's own scope (read:page); the read:label
        scope covers only the site-wide GET /labels endpoint.

        .EXAMPLE
        ```powershell
        Get-ConfluenceLabel -PageId '12345'
        ```

        Lists the labels on page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Labels/Get-ConfluenceLabel/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-label/
    #>
    [CmdletBinding()]
    param(
        # The page id.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId/labels" -All -Context $Context
}
