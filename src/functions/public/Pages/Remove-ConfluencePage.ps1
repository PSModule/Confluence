function Remove-ConfluencePage {
    <#
        .SYNOPSIS
        Delete a Confluence page (delete:page).

        .DESCRIPTION
        Moves a page to the trash. With -Recurse, direct and nested child pages
        are removed first so that a whole subtree can be deleted. With -Purge the
        page is permanently deleted (only valid for already-trashed pages).

        .EXAMPLE
        ```powershell
        Remove-ConfluencePage -PageId '12345' -Recurse
        ```

        Moves page 12345 and its child pages to the trash.

        .LINK
        https://psmodule.io/Confluence/Functions/Pages/Remove-ConfluencePage/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-page/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The page id to delete.
        [Parameter(Mandatory)]
        [string]$PageId,

        # Remove child pages before removing the page itself.
        [switch]$Recurse,

        # Permanently delete instead of moving to trash.
        [switch]$Purge,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($Recurse) {
        $children = Get-ConfluencePageChild -PageId $PageId -Context $Context
        foreach ($child in $children) {
            Remove-ConfluencePage -PageId $child.id -Recurse -Purge:$Purge -Context $Context
        }
    }

    $endpoint = "/wiki/api/v2/pages/$PageId"
    if ($Purge) {
        $endpoint = '{0}?purge=true' -f $endpoint
    }

    if ($PSCmdlet.ShouldProcess($PageId, 'Delete Confluence page')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint $endpoint -Method 'DELETE' -Context $Context
    }
}
