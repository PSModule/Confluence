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

    $dirty = $false
    if ($Force -or -not $stored) {
        $config = ConvertTo-ConfluenceHashtable -InputObject $script:Confluence.DefaultConfig
        $dirty = $true
    } else {
        $config = ConvertTo-ConfluenceHashtable -InputObject $stored
        foreach ($key in $script:Confluence.DefaultConfig.Keys) {
            if (-not $config.ContainsKey($key)) {
                $config[$key] = $script:Confluence.DefaultConfig[$key]
                $dirty = $true
            }
        }
    }

    if ($config['ID'] -ne $id) {
        $config['ID'] = $id
        $dirty = $true
    }

    # Only persist when we actually created or changed the stored config, to avoid
    # unnecessary vault writes on every cmdlet call (this runs from most cmdlets).
    if ($dirty) {
        $null = Set-Context -ID $id -Context $config -Vault $vault
    }
    $script:Confluence.Config = $config
}
