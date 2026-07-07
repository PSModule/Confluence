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
        Get-ConfluenceSpacePermission -SpaceId '123456'
    .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-space-permissions/
    #>
    [CmdletBinding()]
    param(
        # The space id whose permission assignments are returned.
        [Parameter(Mandatory)]
        [string]$SpaceId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/spaces/$SpaceId/permissions" -All -Context $Context
}
