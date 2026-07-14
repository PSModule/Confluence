#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluenceAccessibleResource {
    <#
        .SYNOPSIS
        List the Atlassian sites (resources) a token can reach.

        .DESCRIPTION
        Calls `https://api.atlassian.com/oauth/token/accessible-resources` with the
        token as a bearer credential and returns one object per accessible site.
        Each result exposes the site `id` (which is the cloud ID used in the
        API-gateway base URI), the site `url`, the `name`, and the `scopes` granted
        to the token for that site. Use it to discover the cloud ID and confirm the
        granted scopes before connecting.

        .EXAMPLE
        ```powershell
        $token = Read-Host -AsSecureString
        Get-ConfluenceAccessibleResource -Token $token
        ```

        Lists every site the token can reach, with the cloud ID (`id`), URL and granted scopes.

        .EXAMPLE
        ```powershell
        (Get-ConfluenceAccessibleResource -Token $token | Where-Object url -match 'msxorg').id
        ```

        Returns the cloud ID for the msxorg site from the token's accessible resources.

        .OUTPUTS
        System.Management.Automation.PSObject

        .LINK
        https://psmodule.io/Confluence/Functions/Auth/Get-ConfluenceAccessibleResource/

        .LINK
        https://developer.atlassian.com/cloud/confluence/oauth-2-3lo-apps/#3--make-calls-to-the-api-using-the-access-token
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # The scoped Atlassian API token as a SecureString.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [securestring]$Token
    )

    process {
        $bearer = Resolve-ConfluenceToken -Token $Token
        $headers = @{
            Authorization = "Bearer $bearer"
            Accept        = 'application/json'
        }
        $uri = 'https://api.atlassian.com/oauth/token/accessible-resources'
        Write-Verbose "Listing accessible resources from [$uri]."

        try {
            Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -ErrorAction Stop
        } catch {
            throw "Failed to list accessible resources from [$uri]: $($_.Exception.Message)"
        }
    }
}
