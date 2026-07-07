function Get-ConfluenceSpaceProperty {
    <#
    .SYNOPSIS
        Get space properties (read:space).
    .DESCRIPTION
        Returns all properties on a space, or the single property with the given key.
    .EXAMPLE
        Get-ConfluenceSpaceProperty -SpaceId '123456'
    .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-space-properties/
    #>
    [CmdletBinding()]
    param(
        # The space id.
        [Parameter(Mandatory)]
        [string]$SpaceId,

        # The property key to return. If omitted, all properties are returned.
        [string]$Key,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $all = Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/spaces/$SpaceId/properties" -All -Context $Context
    if ([string]::IsNullOrEmpty($Key)) {
        return $all
    }
    $all | Where-Object { $_.key -eq $Key } | Select-Object -First 1
}
