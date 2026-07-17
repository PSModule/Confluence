#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluenceSpaceProperty {
    <#
        .SYNOPSIS
        Get space properties (read:space).

        .DESCRIPTION
        Returns all properties on a space, or the single property with the given key.

        .EXAMPLE
        ```powershell
        Get-ConfluenceSpaceProperty -SpaceId '123456'
        ```

        Gets all properties on the space with ID 123456.

        .LINK
        https://psmodule.io/Confluence/Functions/Spaces/Get-ConfluenceSpaceProperty/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-space-properties/
    #>
    [OutputType([ConfluenceSpaceProperty])]
    [CmdletBinding()]
    param(
        # The space ID.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $SpaceId,

        # The property key to return. If omitted, all properties are returned.
        [Parameter()]
        [string] $Key,

        # The context to use: an object, a context name, or $null for the default.
        [Parameter()]
        [object] $Context
    )

    $all = Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/spaces/$SpaceId/properties" -All -Context $Context
    if ([string]::IsNullOrEmpty($Key)) {
        foreach ($property in @($all)) {
            ConvertTo-ConfluenceType -InputObject $property -TypeName 'ConfluenceSpaceProperty'
        }
        return
    }

    $match = $all | Where-Object { $_.key -eq $Key } | Select-Object -First 1
    ConvertTo-ConfluenceType -InputObject $match -TypeName 'ConfluenceSpaceProperty'
}
