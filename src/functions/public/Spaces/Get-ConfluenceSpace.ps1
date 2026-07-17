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
    [CmdletBinding(DefaultParameterSetName = 'ListAccessibleSpaces')]
    param(
        # The space key, e.g. 'DOCS'.
        [Parameter(ParameterSetName = 'GetByKeyPattern')]
        [SupportsWildcards()]
        [string]$Key,

        # The space ID.
        [Parameter(Mandatory, ParameterSetName = 'GetById')]
        [string]$Id,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    switch ($PSCmdlet.ParameterSetName) {
        'GetById' {
            return Get-ConfluenceSpaceByIdEndpoint -Id $Id -Context $Context
        }
        'GetByKeyPattern' {
                $allSpaces = @(Get-ConfluenceSpaceListEndpoint -Context $Context)
            $containsWildcard = $Key.IndexOfAny([char[]]@('*', '?', '[')) -ge 0
            if ($containsWildcard) {
                return $allSpaces |
                    Where-Object { $_.key -like $Key }
            }

            return $allSpaces |
                Where-Object { $_.key -eq $Key } |
                Select-Object -First 1
        }
        'ListAccessibleSpaces' {
                return @(Get-ConfluenceSpaceListEndpoint -Context $Context)
        }
        default {
            throw "Unsupported parameter set: $($PSCmdlet.ParameterSetName)"
        }
    }
}
