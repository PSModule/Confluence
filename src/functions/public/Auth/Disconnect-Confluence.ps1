#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Disconnect-Confluence {
    <#
        .SYNOPSIS
        Remove a stored Confluence credential profile.

        .DESCRIPTION
        Deletes the named context from the vault and clears it as the default
        context if it was the current default.

        .EXAMPLE
        ```powershell
        Disconnect-Confluence -Name 'sandbox'
        ```

        Removes the stored 'sandbox' credential profile.

        .LINK
        https://psmodule.io/Confluence/Functions/Auth/Disconnect-Confluence/
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
            # The outer cmdlet already confirmed this operation; suppress the inner cmdlet's
            # ShouldProcess prompt so -Confirm does not trigger a second, nested confirmation.
            Set-ConfluenceConfig -Name 'DefaultContext' -Value '' -Confirm:$false
        }
    }
}
