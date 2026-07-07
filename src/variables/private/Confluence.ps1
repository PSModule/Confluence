$script:Confluence = [pscustomobject]@{
    ContextVault  = 'PSModule.Confluence'
    DefaultConfig = @{
        ID             = 'Module'
        DefaultContext = ''
        PerPage        = 100
    }
    Config        = $null
}
