function Remove-ConfluenceFolder {
    <#
    .SYNOPSIS
        Delete a Confluence folder (delete:folder).
    .DESCRIPTION
        Moves a folder to the trash.
    .EXAMPLE
        Remove-ConfluenceFolder -FolderId '67890'
    .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-folder/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The folder id to delete.
        [Parameter(Mandatory)]
        [string]$FolderId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($PSCmdlet.ShouldProcess($FolderId, 'Delete Confluence folder')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/folders/$FolderId" -Method 'DELETE' -Context $Context
    }
}
