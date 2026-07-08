$script:Confluence = [pscustomobject]@{
    ContextVault  = 'PSModule.Confluence'
    # The API-gateway base is https://api.atlassian.com/ex/confluence/<cloudId>. These are the two
    # Confluence API families that hang off it; the map keeps the version prefixes in one place.
    #   v2 -> <base>/wiki/api/v2/...   (e.g. /wiki/api/v2/spaces)
    #   v1 -> <base>/wiki/rest/api/... (e.g. /wiki/rest/api/content)
    ApiPaths      = @{
        v1 = '/wiki/rest/api'
        v2 = '/wiki/api/v2'
    }
    DefaultConfig = @{
        ID             = 'Module'
        DefaultContext = ''
        PerPage        = 100
    }
    Config        = $null
}
