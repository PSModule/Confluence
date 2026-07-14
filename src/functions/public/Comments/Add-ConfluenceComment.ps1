#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Add-ConfluenceComment {
    <#
        .SYNOPSIS
        Add a footer comment to a page (write:comment).

        .DESCRIPTION
        Creates a footer comment on the given page.

        .EXAMPLE
        ```powershell
        Add-ConfluenceComment -PageId '12345' -Body '<p>Nice page.</p>'
        ```

        Adds a footer comment to page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Comments/Add-ConfluenceComment/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-comment/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The page ID to comment on.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The comment body, as a string in the chosen representation. For 'atlas_doc_format' pass
        # the ADF document serialized as a JSON string (the v2 API stores body.value as a string
        # for every representation).
        [Parameter(Mandatory)]
        [string]$Body,

        # The body representation. Defaults to 'storage'.
        [ValidateSet('storage', 'atlas_doc_format', 'wiki')]
        [string]$Representation = 'storage',

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $payload = @{
        pageId = $PageId
        body   = @{
            representation = $Representation
            value          = $Body
        }
    }

    if ($PSCmdlet.ShouldProcess($PageId, 'Add footer comment')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/footer-comments' -Method 'POST' -Body $payload -Context $Context
    }
}
