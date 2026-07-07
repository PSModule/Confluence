function Get-ConfluenceSiteInfo {
    <#
        .SYNOPSIS
        Get basic information about the connected Confluence site (read:space or read:page).

        .DESCRIPTION
        Returns the site's cloud id (parsed from the API-gateway base URI) and
        the browsable site (wiki) base URL (read from the API's _links.base). A
        scoped v2 token cannot reach the dedicated site/settings endpoints (site
        name, edition, build number) — those are v1-only and are rejected.

        .EXAMPLE
        ```powershell
        Get-ConfluenceSiteInfo
        ```

        Returns the cloud ID and browsable site URL for the connected site.

        .LINK
        https://psmodule.io/Confluence/Functions/Site/Get-ConfluenceSiteInfo/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-space/
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $resolved = Resolve-ConfluenceContext -Context $Context
    $cloudId = if ($resolved.ApiBaseUri -match '/ex/confluence/([0-9a-fA-F-]+)') { $Matches[1] } else { $null }

    # _links.base (the browsable site URL) appears on any v2 collection response;
    # try a couple so this works whether the token has read:space or only read:page.
    $siteUrl = $null
    foreach ($probe in '/wiki/api/v2/spaces', '/wiki/api/v2/pages') {
        try {
            $response = Invoke-ConfluenceRestMethod -ApiEndpoint $probe -Query @{ limit = 1 } -Context $Context
            if ($response._links.base) {
                $siteUrl = $response._links.base
                break
            }
        } catch {
            continue
        }
    }

    [pscustomobject]@{
        CloudId    = $cloudId
        ApiBaseUri = $resolved.ApiBaseUri
        SiteUrl    = $siteUrl
    }
}
