function Set-ConfluenceConfig {
    <#
        .SYNOPSIS
        Set a Confluence module configuration value.

        .DESCRIPTION
        Updates a single configuration item and persists the configuration to
        the context vault.

        .EXAMPLE
        ```powershell
        Set-ConfluenceConfig -Name 'PerPage' -Value 50
        ```

        Sets the PerPage configuration value to 50.

        .LINK
        https://psmodule.io/Confluence/Functions/Config/Set-ConfluenceConfig/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The configuration item name.
        [Parameter(Mandatory)]
        [string]$Name,

        # The value to store.
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [object]$Value
    )

    Initialize-ConfluenceConfig
    if ($PSCmdlet.ShouldProcess("Confluence config '$Name'", 'Set')) {
        $script:Confluence.Config[$Name] = $Value
        $null = Set-Context -ID $script:Confluence.DefaultConfig.ID -Context $script:Confluence.Config -Vault $script:Confluence.ContextVault
    }
}
