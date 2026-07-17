#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluenceFolder {
    <#
        .SYNOPSIS
        Get a Confluence folder by ID (read:folder).

        .DESCRIPTION
        Returns a single folder.

        .EXAMPLE
        ```powershell
        Get-ConfluenceFolder -FolderId '67890'
        ```

        Gets the folder with ID 67890.

        .LINK
        https://psmodule.io/Confluence/Functions/Folders/Get-ConfluenceFolder/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-folder/
    #>
    [OutputType([ConfluenceFolder])]
    [CmdletBinding()]
    param(
        # The folder ID.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $FolderId,

        # The context to use: an object, a context name, or $null for the default.
        [Parameter()]
        [object] $Context
    )

    $folder = Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/folders/$FolderId" -Context $Context
    ConvertTo-ConfluenceType -InputObject $folder -TypeName 'ConfluenceFolder'
}
