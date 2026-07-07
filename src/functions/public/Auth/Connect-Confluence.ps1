function Connect-Confluence {
    <#
        .SYNOPSIS
        Connect to Confluence and store a credential profile in the context vault.

        .DESCRIPTION
        Validates the supplied credentials with a lightweight authenticated call,
        stores them as a named context (the token is kept as a SecureString), and
        records the context as the module default. A token that authenticates but
        lacks the read:space scope still connects (with a warning).

        .EXAMPLE
        ```powershell
        $token = Read-Host -AsSecureString
        Connect-Confluence -ApiBaseUri $uri -Username $user -Token $token -SpaceKey 'DOCS'
        ```

        Connects with a scoped token and stores the profile with 'DOCS' as the default space.

        .LINK
        https://psmodule.io/Confluence/Functions/Auth/Connect-Confluence/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/intro/#auth

        .LINK
        https://developer.atlassian.com/cloud/confluence/scopes-for-oauth-2-3LO-and-forge-apps/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([pscustomobject])]
    param(
        # The Confluence API-gateway base URI, e.g. 'https://api.atlassian.com/ex/confluence/<cloudId>'.
        [Parameter(Mandatory)]
        [string]$ApiBaseUri,

        # The service-account user (email) used for HTTP Basic authentication.
        [Parameter(Mandatory)]
        [string]$Username,

        # The scoped Atlassian API token as a SecureString.
        [Parameter(Mandatory)]
        [securestring]$Token,

        # The context name to store the profile under. Defaults to '<host>/<cloudId>/<user>'.
        [string]$Name,

        # An optional default space key stored with the profile.
        [string]$SpaceKey,

        # Return the stored context.
        [switch]$PassThru
    )

    if ([string]::IsNullOrEmpty($Name)) {
        # api.atlassian.com is shared by every Confluence Cloud site, so the host
        # alone is not unique. Include the trailing base-URI path segment (the
        # cloudId for the API gateway) so each site gets a distinct default name.
        $baseUri = [uri]$ApiBaseUri
        $siteId = @($baseUri.AbsolutePath.Trim('/') -split '/') | Where-Object { $_ } | Select-Object -Last 1
        $Name = if ($siteId) {
            '{0}/{1}/{2}' -f $baseUri.Host, $siteId, $Username
        } else {
            '{0}/{1}' -f $baseUri.Host, $Username
        }
    }

    if ($Name -eq $script:Confluence.DefaultConfig.ID) {
        throw "The context name '$Name' is reserved for the module configuration; choose a different -Name."
    }

    $context = @{
        ID         = $Name
        Name       = $Name
        Type       = 'Confluence'
        ApiBaseUri = $ApiBaseUri.TrimEnd('/')
        Username   = $Username
        Token      = $Token
        SpaceKey   = $SpaceKey
    }

    if (-not $PSCmdlet.ShouldProcess($Name, 'Connect to Confluence and store credential context')) {
        return
    }

    # Validate the credentials before persisting them. A scope-check rejection
    # still proves the token authenticated (it merely lacks read:space); only a
    # genuine authentication failure is fatal.
    try {
        $null = Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/spaces' -Query @{ limit = 1 } -Context $context
    } catch {
        if ($_.Exception.Message -notmatch 'FAILURE_CLIENT_SCOPE_CHECK|scope does not match') {
            throw
        }
        Write-Warning "Token authenticated but lacks read:space; space listing is unavailable for context '$Name'."
    }

    $stored = Set-Context -ID $Name -Context $context -Vault $script:Confluence.ContextVault -PassThru
    Set-ConfluenceConfig -Name 'DefaultContext' -Value $Name

    if ($PassThru) {
        $stored
    }
}
