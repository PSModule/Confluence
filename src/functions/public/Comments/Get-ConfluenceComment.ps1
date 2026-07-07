function Get-ConfluenceComment {
    <#
    .SYNOPSIS
        List the footer comments on a page (read:comment).
    .DESCRIPTION
        Returns every footer comment on the page, following pagination.
    .EXAMPLE
        Get-ConfluenceComment -PageId '12345'
    .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-comment/
    #>
    [CmdletBinding()]
    param(
        # The page id.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId/footer-comments" -All -Context $Context
}
