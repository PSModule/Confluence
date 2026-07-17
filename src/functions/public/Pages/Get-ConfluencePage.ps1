#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluencePage {
    <#
        .SYNOPSIS
        Get a Confluence page by ID (read:page).

        .DESCRIPTION
        Returns a single page, including its body in the requested format.

        .EXAMPLE
        ```powershell
        Get-ConfluencePage -PageId '12345'
        ```

        Gets page 12345, including its body in storage format.

        .LINK
        https://psmodule.io/Confluence/Functions/Pages/Get-ConfluencePage/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-page/
    #>
    [OutputType([ConfluencePage])]
    [CmdletBinding()]
    param(
        # The page ID.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $PageId,

        # The body format to return. Defaults to 'storage'.
        [Parameter()]
        [ValidateSet('storage', 'atlas_doc_format', 'view', 'export_view', 'anonymous_export_view', 'styled_view', 'editor')]
        [string] $BodyFormat = 'storage',

        # The context to use: an object, a context name, or $null for the default.
        [Parameter()]
        [object] $Context
    )

    $page = Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId" -Query @{ 'body-format' = $BodyFormat } -Context $Context
    ConvertTo-ConfluenceType -InputObject $page -TypeName 'ConfluencePage'
}
