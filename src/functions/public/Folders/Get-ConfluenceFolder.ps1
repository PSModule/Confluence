function Get-ConfluenceFolder {
    <#
    .SYNOPSIS
        Get a Confluence folder by id (read:folder).
    .DESCRIPTION
        Returns a single folder.
    .EXAMPLE
        Get-ConfluenceFolder -FolderId '67890'
    .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-folder/
    #>
    [CmdletBinding()]
    param(
        # The folder id.
        [Parameter(Mandatory)]
        [string]$FolderId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/folders/$FolderId" -Context $Context
}
