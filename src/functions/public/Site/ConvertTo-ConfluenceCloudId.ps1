#SkipTest:FunctionTest:Resolves the cloud ID from the public tenant_info endpoint; covered by integration tests.
function ConvertTo-ConfluenceCloudId {
    <#
        .SYNOPSIS
        Resolve a Confluence Cloud site to its cloud ID.

        .DESCRIPTION
        Looks up the cloud ID for an Atlassian Confluence Cloud site from the
        public `/_edge/tenant_info` endpoint, so a caller can supply a site name or
        URL instead of the cloud ID. Accepts a bare subdomain (`myorg`), a host
        (`myorg.atlassian.net`), or any URL on the site
        (`https://myorg.atlassian.net/wiki/...`). No authentication is required.

        .EXAMPLE
        ```powershell
        ConvertTo-ConfluenceCloudId -Site 'msxorg'
        ```

        Returns the cloud ID for `https://msxorg.atlassian.net`.

        .EXAMPLE
        ```powershell
        'https://msxorg.atlassian.net/wiki/spaces/DOCS' | ConvertTo-ConfluenceCloudId
        ```

        Resolves the cloud ID from a full site URL supplied through the pipeline.

        .EXAMPLE
        ```powershell
        $cloudId = ConvertTo-ConfluenceCloudId -Site 'msxorg'
        Connect-Confluence -ApiBaseUri "https://api.atlassian.com/ex/confluence/$cloudId" -Username $user -Token $token
        ```

        Uses the resolved cloud ID to build the API-gateway base URI for `Connect-Confluence`,
        so the caller only needs the site name.

        .OUTPUTS
        System.String

        .LINK
        https://psmodule.io/Confluence/Functions/Site/ConvertTo-ConfluenceCloudId/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/intro/#about
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The site to resolve: a subdomain (`myorg`), a host (`myorg.atlassian.net`),
        # or any URL on the site (`https://myorg.atlassian.net/...`).
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Url', 'Uri', 'Name')]
        [string]$Site
    )

    process {
        $trimmed = $Site.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            throw 'The -Site value cannot be empty.'
        }

        # Derive the host whether the caller passed a bare subdomain, a host, or a URL.
        $siteHost = if ($trimmed -match '^[A-Za-z][A-Za-z0-9+.-]*://') {
            ([uri]$trimmed).Host
        } elseif ($trimmed -match '[/.]') {
            ([uri]"https://$trimmed").Host
        } else {
            "$trimmed.atlassian.net"
        }

        if ([string]::IsNullOrWhiteSpace($siteHost)) {
            throw "Could not determine the site host from '$Site'."
        }

        $tenantInfoUri = "https://$siteHost/_edge/tenant_info"
        Write-Verbose "Resolving cloud ID from [$tenantInfoUri]."

        try {
            $tenantInfo = Invoke-RestMethod -Uri $tenantInfoUri -Method Get -ErrorAction Stop
        } catch {
            throw "Failed to resolve the cloud ID for '$siteHost' from [$tenantInfoUri]: $($_.Exception.Message)"
        }

        if ([string]::IsNullOrWhiteSpace($tenantInfo.cloudId)) {
            throw "The endpoint [$tenantInfoUri] did not return a cloud ID for '$siteHost'."
        }

        $tenantInfo.cloudId
    }
}
