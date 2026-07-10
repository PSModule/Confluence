#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Set-ConfluenceSpace {
    <#
        .SYNOPSIS
        Create or declaratively configure a Confluence space (read:space and write:space).

        .DESCRIPTION
        Ensures a space matches the supplied configuration (a declarative upsert).
        If no space with the key exists it is created; if it exists it is updated.
        Unlike Update-ConfluenceSpace, this is a full-state set: properties that are
        not supplied are reset to their defaults (omitting -Description clears it).
        To change individual fields while preserving the rest, use
        Update-ConfluenceSpace. Space create/update are v1-only operations reached
        over the API gateway; creating a space also needs the global "Create Spaces"
        permission.

        .EXAMPLE
        ```powershell
        Set-ConfluenceSpace -Key 'DOCS' -Name 'Documentation' -Description 'Team docs'
        ```

        Creates the 'DOCS' space if it is missing, otherwise updates it, so its name
        and description match exactly what was supplied.

        .EXAMPLE
        ```powershell
        Set-ConfluenceSpace -Key 'DOCS' -Name 'Documentation'
        ```

        Declaratively sets 'DOCS' with no description, clearing any existing description.

        .LINK
        https://psmodule.io/Confluence/Functions/Spaces/Set-ConfluenceSpace/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v1/api-group-space/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The key of the space to create or configure.
        [Parameter(Mandatory)]
        [string]$Key,

        # The desired display name. A space always requires a name.
        [Parameter(Mandatory)]
        [string]$Name,

        # The desired plain-text description. Omit to clear the description.
        [string]$Description,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    # Declarative: the supplied parameters are the full desired state, so an omitted
    # -Description resets the description to empty rather than preserving it.
    $payload = @{
        key         = $Key
        name        = $Name
        description = @{
            plain = @{
                value          = [string]$Description
                representation = 'plain'
            }
        }
    }

    # Look the space up to choose between create (POST) and update (PUT).
    $response = Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/spaces' -Query @{ keys = $Key } -Context $Context
    $existing = $response.results | Where-Object { $_.key -eq $Key } | Select-Object -First 1

    if ($existing) {
        if ($PSCmdlet.ShouldProcess($Key, 'Set Confluence space (update existing)')) {
            Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/rest/api/space/$Key" -Method 'PUT' -Body $payload -Context $Context
        }
    } else {
        if ($PSCmdlet.ShouldProcess($Key, 'Set Confluence space (create)')) {
            Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/rest/api/space' -Method 'POST' -Body $payload -Context $Context
        }
    }
}
