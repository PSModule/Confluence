function Remove-ConfluencePage {
    <#
        .SYNOPSIS
        Delete a Confluence page (delete:page).

        .DESCRIPTION
        Moves a page to the trash. With -Recurse, direct and nested child pages
        are removed first so that a whole subtree can be deleted. With -Purge the
        page is permanently deleted: because Confluence requires a page to be in
        the trash before it can be purged, the page is trashed first and then
        purged in a second call.

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

        # Permanently delete the page. It is moved to the trash first (as the API
        # requires) and then purged.
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

    $base = "/wiki/api/v2/pages/$PageId"
    $action = if ($Purge) { 'Permanently delete Confluence page' } else { 'Delete Confluence page' }

    if ($PSCmdlet.ShouldProcess($PageId, $action)) {
        if ($Purge) {
            # A page must be in the trash before it can be purged. Trash first
            # (ignoring failures, e.g. when it is already trashed), then purge.
            try {
                Invoke-ConfluenceRestMethod -ApiEndpoint $base -Method 'DELETE' -Context $Context
            } catch {
                Write-Verbose "Trash step before purge failed (the page may already be trashed): $($_.Exception.Message)"
            }
            Invoke-ConfluenceRestMethod -ApiEndpoint ('{0}?purge=true' -f $base) -Method 'DELETE' -Context $Context
        } else {
            Invoke-ConfluenceRestMethod -ApiEndpoint $base -Method 'DELETE' -Context $Context
        }
    }
}
