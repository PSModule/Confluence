function Remove-ConfluenceComment {
    <#
    .SYNOPSIS
        Delete a footer comment (delete:comment).
    .DESCRIPTION
        Permanently deletes a footer comment by id.
    .EXAMPLE
        Remove-ConfluenceComment -CommentId '55555'
    .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-comment/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The footer comment id.
        [Parameter(Mandatory)]
        [string]$CommentId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($PSCmdlet.ShouldProcess($CommentId, 'Delete footer comment')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/footer-comments/$CommentId" -Method 'DELETE' -Context $Context
    }
}
