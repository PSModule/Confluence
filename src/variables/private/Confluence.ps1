$script:Confluence = [pscustomobject]@{
    ContextVault  = 'PSModule.Confluence'
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
