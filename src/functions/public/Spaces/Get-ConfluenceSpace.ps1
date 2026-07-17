#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluenceSpace {
    <#
        .SYNOPSIS
        Get a Confluence space (read:space).

        .DESCRIPTION
        Returns spaces the connected user can access. Without parameters, lists
        all accessible spaces. With -Id, returns that exact space by ID. With
        -Key, returns an exact key match; wildcard keys are supported and return
        all matching spaces.

        .EXAMPLE
        ```powershell
        Get-ConfluenceSpace -Key 'DOCS'
        ```

        Gets the space with key 'DOCS'.

        .EXAMPLE
        ```powershell
        Get-ConfluenceSpace
        ```

        Lists all spaces visible to the connected user.

        .EXAMPLE
        ```powershell
        Get-ConfluenceSpace -Key 'AIT*'
        ```

        Returns all spaces with keys that start with 'AIT'.

        .LINK
        https://psmodule.io/Confluence/Functions/Spaces/Get-ConfluenceSpace/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-space/
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByKey')]
    param(
        # The space key, e.g. 'DOCS'.
        [Parameter(ParameterSetName = 'ByKey')]
        [SupportsWildcards()]
        [string]$Key,

        # The space ID.
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$Id,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($PSCmdlet.ParameterSetName -eq 'ById') {
        return Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/spaces/$Id" -Context $Context
    }

    if ([string]::IsNullOrEmpty($Key)) {
        return @(Invoke-ConfluenceRestMethod -ApiVersion 'v2' -ApiEndpoint 'spaces' -All -Context $Context)
    }

    $containsWildcard = $Key.IndexOfAny([char[]]@('*', '?', '[')) -ge 0
    if ($containsWildcard) {
        return @(Invoke-ConfluenceRestMethod -ApiVersion 'v2' -ApiEndpoint 'spaces' -All -Context $Context) |
            Where-Object { $_.key -like $Key }
    }

    $response = Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/spaces' -Query @{ keys = $Key } -Context $Context
    $response.results | Where-Object { $_.key -eq $Key } | Select-Object -First 1
}
