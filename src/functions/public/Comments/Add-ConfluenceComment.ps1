function Add-ConfluenceComment {
    <#
    .SYNOPSIS
        Add a footer comment to a page (write:comment).
    .DESCRIPTION
        Creates a footer comment on the given page.
    .EXAMPLE
        Add-ConfluenceComment -PageId '12345' -Body '<p>Nice page.</p>'
    .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-comment/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The page id to comment on.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The comment body.
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
