#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluenceSpace {
    <#
        .SYNOPSIS
        Get a Confluence space (read:space).

        .DESCRIPTION
        Returns a space by key or by ID. When neither is supplied the default
        space key from the connected context is used.

        .EXAMPLE
        ```powershell
        Get-ConfluenceSpace -Key 'DOCS'
        ```

        Gets the space with key 'DOCS'.

        .LINK
        https://psmodule.io/Confluence/Functions/Spaces/Get-ConfluenceSpace/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-space/
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByKey')]
    param(
        # The space key, e.g. 'DOCS'.
        [Parameter(ParameterSetName = 'ByKey')]
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
        $resolved = Resolve-ConfluenceContext -Context $Context
        $Key = $resolved.SpaceKey
    }
    if ([string]::IsNullOrEmpty($Key)) {
        throw 'Specify -Key or -Id, or connect with a default SpaceKey.'
    }

    $response = Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/spaces' -Query @{ keys = $Key } -Context $Context
    $response.results | Where-Object { $_.key -eq $Key } | Select-Object -First 1
}
