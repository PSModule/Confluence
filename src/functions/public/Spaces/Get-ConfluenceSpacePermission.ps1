#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluenceSpacePermission {
    <#
        .SYNOPSIS
        List the permission assignments on a space (read:space).

        .DESCRIPTION
        Returns every permission assignment in the space — each entry pairs a
        principal (user or group) with an operation (for example read/space,
        create/page, delete/page, restrict_content/space). This is the space's
        whole permission table, not a filtered "effective permissions for the
        current user" view (Confluence exposes that only on the v1 operations
        expansion, which a granular v2 token cannot call).

        .EXAMPLE
        ```powershell
        Get-ConfluenceSpacePermission -SpaceId '123456'
        ```

        Lists the permission assignments in the space with ID 123456.

        .LINK
        https://psmodule.io/Confluence/Functions/Spaces/Get-ConfluenceSpacePermission/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-space-permissions/
    #>
    [CmdletBinding()]
    param(
        # The space ID whose permission assignments are returned.
        [Parameter(Mandatory)]
        [string]$SpaceId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/spaces/$SpaceId/permissions" -All -Context $Context
}
