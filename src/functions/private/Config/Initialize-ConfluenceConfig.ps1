function Initialize-ConfluenceConfig {
    <#
    .SYNOPSIS
        Load the module configuration from the context vault into memory.
    .DESCRIPTION
        Loads the stored 'Module' configuration context, creating it from the
        built-in defaults on first use. Missing default keys are backfilled.
    #>
    [CmdletBinding()]
    param(
        # Recreate the configuration from the built-in defaults.
        [switch]$Force
    )

    if (-not $Force -and $null -ne $script:Confluence.Config) {
        return
    }

    $vault = $script:Confluence.ContextVault
    $id = $script:Confluence.DefaultConfig.ID

    $stored = $null
    if (-not $Force) {
        try {
            $stored = Get-Context -ID $id -Vault $vault -ErrorAction Stop
        } catch {
            $stored = $null
        }
    }

    if ($Force -or -not $stored) {
        $config = ConvertTo-ConfluenceHashtable -InputObject $script:Confluence.DefaultConfig
    } else {
        $config = ConvertTo-ConfluenceHashtable -InputObject $stored
        foreach ($key in $script:Confluence.DefaultConfig.Keys) {
            if (-not $config.ContainsKey($key)) {
                $config[$key] = $script:Confluence.DefaultConfig[$key]
            }
        }
    }

    $config['ID'] = $id
    $null = Set-Context -ID $id -Context $config -Vault $vault
    $script:Confluence.Config = $config
}
