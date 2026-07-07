function Disconnect-Confluence {
    <#
    .SYNOPSIS
        Remove a stored Confluence credential profile.
    .DESCRIPTION
        Deletes the named context from the vault and clears it as the default
        context if it was the current default.
    .EXAMPLE
        Disconnect-Confluence -Name 'sandbox'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The context name to remove. Defaults to the current default context.
        [string]$Name
    )

    Initialize-ConfluenceConfig
    if ([string]::IsNullOrEmpty($Name)) {
        $Name = $script:Confluence.Config['DefaultContext']
    }
    if ([string]::IsNullOrEmpty($Name)) {
        return
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Remove Confluence credential context')) {
        Remove-Context -ID $Name -Vault $script:Confluence.ContextVault -ErrorAction SilentlyContinue
        if ($script:Confluence.Config['DefaultContext'] -eq $Name) {
            Set-ConfluenceConfig -Name 'DefaultContext' -Value ''
        }
    }
}
