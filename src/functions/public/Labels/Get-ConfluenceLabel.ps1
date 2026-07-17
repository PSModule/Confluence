#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
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
    [OutputType([ConfluenceLabel])]
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

    foreach ($label in @(Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId/labels" -All -Context $Context)) {
        ConvertTo-ConfluenceType -InputObject $label -TypeName 'ConfluenceLabel'
    }
}
