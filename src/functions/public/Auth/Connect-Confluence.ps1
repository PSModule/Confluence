#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Connect-Confluence {
    <#
        .SYNOPSIS
        Connect to Confluence and store a credential profile in the context vault.

        .DESCRIPTION
        Validates the supplied credentials with a lightweight authenticated call,
        stores them as a named context (the token is kept as a SecureString), and
        records the context as the module default. Supply the site with -Site (a
        name such as 'msxorg', a host, or a URL) and the cloud ID is resolved
        automatically; or pass a known -CloudId directly to skip the lookup. A
        token that authenticates but lacks the read:space scope still connects
        (with a warning).

        .EXAMPLE
        ```powershell
        $token = Read-Host -AsSecureString
        Connect-Confluence -Site 'msxorg' -Username $user -Token $token -SpaceKey 'DOCS'
        ```

        Resolves the cloud ID for msxorg.atlassian.net, connects, and stores 'DOCS' as the default space.

        .EXAMPLE
        ```powershell
        Connect-Confluence -CloudId 'fff64f40-36b7-4578-92be-b9d9b6b17658' -Username $user -Token $token
        ```

        Connects directly with a known cloud ID, skipping the site lookup.

        .LINK
        https://psmodule.io/Confluence/Functions/Auth/Connect-Confluence/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/intro/#auth

        .LINK
        https://developer.atlassian.com/cloud/confluence/scopes-for-oauth-2-3LO-and-forge-apps/
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Site')]
    [OutputType([pscustomobject])]
    param(
        # The Confluence Cloud site: a name (`msxorg`), a host (`msxorg.atlassian.net`),
        # or any URL on the site. The cloud ID is resolved automatically.
        [Parameter(Mandatory, ParameterSetName = 'Site')]
        [string]$Site,

        # The Confluence Cloud ID - a faster alternative to -Site that skips the lookup.
        # Find it with `Get-ConfluenceCloudId` or `Get-ConfluenceAccessibleResource`.
        [Parameter(Mandatory, ParameterSetName = 'CloudId')]
        [string]$CloudId,

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

    if ($PSCmdlet.ParameterSetName -eq 'Site') {
        # Resolve a site name/host/URL to its cloud ID via the public tenant_info endpoint.
        $CloudId = Get-ConfluenceCloudId -Site $Site
    }
    # The scoped-token gateway base is always api.atlassian.com/ex/confluence/<cloudId>.
    $ApiBaseUri = 'https://api.atlassian.com/ex/confluence/{0}' -f $CloudId

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
        Scopes     = @()
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

    # Best-effort: record the scopes the token holds for this site (from the
    # accessible-resources endpoint) so the stored context reflects what we can do.
    # Never fail the connection if scope discovery is unavailable for this token.
    try {
        $resource = Get-ConfluenceAccessibleResource -Token $Token | Where-Object { $_.id -eq $CloudId } | Select-Object -First 1
        if ($resource -and $resource.scopes) {
            $context['Scopes'] = @($resource.scopes)
            Write-Verbose "Recorded $($context['Scopes'].Count) scope(s) for context '$Name'."
        }
    } catch {
        Write-Verbose "Could not resolve token scopes from accessible-resources: $($_.Exception.Message)"
    }

    $stored = Set-Context -ID $Name -Context $context -Vault $script:Confluence.ContextVault -PassThru
    Set-ConfluenceConfig -Name 'DefaultContext' -Value $Name

    if ($PassThru) {
        $stored
    }
}
