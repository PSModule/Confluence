#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Remove-ConfluenceFolder {
    <#
        .SYNOPSIS
        Delete a Confluence folder (delete:folder).

        .DESCRIPTION
        Moves a folder to the trash.

        .EXAMPLE
        ```powershell
        Remove-ConfluenceFolder -FolderId '67890'
        ```

        Moves the folder with ID 67890 to the trash.

        .LINK
        https://psmodule.io/Confluence/Functions/Folders/Remove-ConfluenceFolder/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-folder/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The folder ID to delete.
        [Parameter(Mandatory)]
        [string]$FolderId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($PSCmdlet.ShouldProcess($FolderId, 'Delete Confluence folder')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/folders/$FolderId" -Method 'DELETE' -Context $Context
    }
}
