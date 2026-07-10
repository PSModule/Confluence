#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function New-ConfluenceFolder {
    <#
        .SYNOPSIS
        Create a Confluence folder (write:folder).

        .DESCRIPTION
        Creates a folder in a space, optionally beneath a parent page or folder.

        .EXAMPLE
        ```powershell
        New-ConfluenceFolder -SpaceId $spaceId -Title 'Archive' -ParentId $pageId
        ```

        Creates a folder named 'Archive' beneath the given parent.

        .LINK
        https://psmodule.io/Confluence/Functions/Folders/New-ConfluenceFolder/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-folder/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The id of the space to create the folder in.
        [Parameter(Mandatory)]
        [string]$SpaceId,

        # The folder title.
        [Parameter(Mandatory)]
        [string]$Title,

        # The id of the parent page or folder. Omit to create at the space root.
        [string]$ParentId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $payload = @{
        spaceId = $SpaceId
        title   = $Title
    }
    if (-not [string]::IsNullOrEmpty($ParentId)) {
        $payload['parentId'] = $ParentId
    }

    if ($PSCmdlet.ShouldProcess($Title, 'Create Confluence folder')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/folders' -Method 'POST' -Body $payload -Context $Context
    }
}
