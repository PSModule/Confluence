function Get-ConfluencePage {
    <#
    .SYNOPSIS
        Get a Confluence page by id (read:page).
    .DESCRIPTION
        Returns a single page, including its body in the requested format.
    .EXAMPLE
        Get-ConfluencePage -PageId '12345'
    .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-page/
    #>
    [CmdletBinding()]
    param(
        # The page id.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The body format to return. Defaults to 'storage'.
        [ValidateSet('storage', 'atlas_doc_format', 'view', 'export_view', 'anonymous_export_view', 'styled_view', 'editor')]
        [string]$BodyFormat = 'storage',

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId" -Query @{ 'body-format' = $BodyFormat } -Context $Context
}
