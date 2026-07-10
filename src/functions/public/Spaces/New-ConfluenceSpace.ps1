#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function New-ConfluenceSpace {
    <#
        .SYNOPSIS
        Create a Confluence space (write:space).

        .DESCRIPTION
        Creates a new global space with the given key and name, setting the
        properties you supply. Fails if a space with that key already exists.
        Space creation is
        a v1-only operation (the v2 API exposes no space-write endpoint) reached
        over the API gateway with the granular write:space scope; it also needs
        the global "Create Spaces" permission on the account. The creating account
        becomes an administrator of the new space.

        .EXAMPLE
        ```powershell
        New-ConfluenceSpace -Key 'DOCS' -Name 'Documentation' -Description 'Team docs'
        ```

        Creates a global space with key 'DOCS' named 'Documentation'.

        .LINK
        https://psmodule.io/Confluence/Functions/Spaces/New-ConfluenceSpace/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v1/api-group-space/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The unique key for the new space (letters and numbers).
        [Parameter(Mandatory)]
        [string]$Key,

        # The display name of the new space.
        [Parameter(Mandatory)]
        [string]$Name,

        # An optional plain-text space description.
        [string]$Description,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $payload = @{
        key  = $Key
        name = $Name
    }
    if (-not [string]::IsNullOrEmpty($Description)) {
        $payload['description'] = @{
            plain = @{
                value          = $Description
                representation = 'plain'
            }
        }
    }

    if ($PSCmdlet.ShouldProcess($Key, 'Create Confluence space')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/rest/api/space' -Method 'POST' -Body $payload -Context $Context
    }
}
