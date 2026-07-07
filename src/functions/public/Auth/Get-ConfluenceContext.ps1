function Get-ConfluenceContext {
    <#
        .SYNOPSIS
        Get a stored Confluence credential profile.

        .DESCRIPTION
        Returns the named context, the default context, or (with -ListAvailable)
        all stored Confluence contexts. The token remains a SecureString.

        .EXAMPLE
        ```powershell
        Get-ConfluenceContext
        ```

        Returns the current default context.

        .LINK
        https://psmodule.io/Confluence/Functions/Auth/Get-ConfluenceContext/
    #>
    [CmdletBinding(DefaultParameterSetName = 'Single')]
    [OutputType([pscustomobject])]
    param(
        # The context name to return. Defaults to the current default context.
        [Parameter(ParameterSetName = 'Single')]
        [string]$Name,

        # Return every Confluence context stored in the vault.
        [Parameter(ParameterSetName = 'List')]
        [switch]$ListAvailable
    )

    if ($ListAvailable) {
        return Get-Context -Vault $script:Confluence.ContextVault | Where-Object { $_.ID -ne $script:Confluence.DefaultConfig.ID }
    }

    Initialize-ConfluenceConfig
    if ([string]::IsNullOrEmpty($Name)) {
        $Name = $script:Confluence.Config['DefaultContext']
    }
    if ([string]::IsNullOrEmpty($Name)) {
        throw 'No context name specified and no default context is set.'
    }
    Get-Context -ID $Name -Vault $script:Confluence.ContextVault
}
