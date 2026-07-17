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
    [OutputType([ConfluenceSpace])]
    [CmdletBinding(DefaultParameterSetName = 'ListAccessibleSpaces')]
    param(
        # The space key, e.g. 'DOCS'.
        [Parameter(ParameterSetName = 'GetByKeyPattern')]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [string] $Key,

        # The space ID.
        [Parameter(Mandatory, ParameterSetName = 'GetById')]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        # The context to use: an object, a context name, or $null for the default.
        [Parameter()]
        [object] $Context
    )

    switch ($PSCmdlet.ParameterSetName) {
        'GetById' {
            $space = Get-ConfluenceSpaceByIdEndpoint -Id $Id -Context $Context
            ConvertTo-ConfluenceType -InputObject $space -TypeName 'ConfluenceSpace'
        }
        'GetByKeyPattern' {
            $allSpaces = @(Get-ConfluenceSpaceListEndpoint -Context $Context)
            $containsWildcard = $Key.IndexOfAny([char[]]@('*', '?', '[')) -ge 0
            if ($containsWildcard) {
                foreach ($space in ($allSpaces | Where-Object { $_.key -like $Key })) {
                    ConvertTo-ConfluenceType -InputObject $space -TypeName 'ConfluenceSpace'
                }
                break
            }

            $exactSpace = $allSpaces |
                Where-Object { $_.key -eq $Key } |
                Select-Object -First 1

            ConvertTo-ConfluenceType -InputObject $exactSpace -TypeName 'ConfluenceSpace'
        }
        'ListAccessibleSpaces' {
            foreach ($space in @(Get-ConfluenceSpaceListEndpoint -Context $Context)) {
                ConvertTo-ConfluenceType -InputObject $space -TypeName 'ConfluenceSpace'
            }
        }
        default {
            throw "Unsupported parameter set: $($PSCmdlet.ParameterSetName)"
        }
    }
}
