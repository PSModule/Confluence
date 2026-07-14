#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Update-ConfluenceSpace {
    <#
        .SYNOPSIS
        Update a Confluence space's name or description (read:space and write:space).

        .DESCRIPTION
        Updates one or more properties (name and/or description) on an existing
        space. Only the fields you supply change; unspecified fields keep their
        current values, because the space is read first (read:space) and then
        written back (write:space). Fails if the space does not exist. For a
        declarative create-or-replace, use Set-ConfluenceSpace instead. Updating a
        space is a v1-only operation reached over the API gateway.

        .EXAMPLE
        ```powershell
        Update-ConfluenceSpace -Key 'DOCS' -Name 'Team Documentation'
        ```

        Renames the 'DOCS' space, keeping its existing description.

        .LINK
        https://psmodule.io/Confluence/Functions/Spaces/Update-ConfluenceSpace/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v1/api-group-space/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The key of the space to update.
        [Parameter(Mandatory)]
        [string]$Key,

        # The new display name. Defaults to the existing name.
        [string]$Name,

        # The new plain-text description. Defaults to the existing description.
        [string]$Description,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    # Read the current space (with its plain-text description) so a caller who
    # updates only one field does not blank the other on the full-body v1 PUT.
    $query = @{ keys = $Key; 'description-format' = 'plain' }
    $response = Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/spaces' -Query $query -Context $Context
    $current = $response.results | Where-Object { $_.key -eq $Key } | Select-Object -First 1
    if (-not $current) {
        throw "Confluence space '$Key' was not found."
    }

    $newName = if ($PSBoundParameters.ContainsKey('Name')) { $Name } else { $current.name }
    $newDescription = if ($PSBoundParameters.ContainsKey('Description')) {
        $Description
    } else {
        # 'description' is optional in the v2 space response, so navigate it defensively:
        # a space without one preserves an empty description instead of failing (and stays
        # safe under Set-StrictMode, where blindly dereferencing a missing member throws).
        if ($current.description -and $current.description.plain) {
            [string]$current.description.plain.value
        } else {
            ''
        }
    }

    $payload = @{
        key         = $Key
        name        = $newName
        description = @{
            plain = @{
                value          = $newDescription
                representation = 'plain'
            }
        }
    }

    if ($PSCmdlet.ShouldProcess($Key, 'Update Confluence space')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/rest/api/space/$Key" -Method 'PUT' -Body $payload -Context $Context
    }
}
