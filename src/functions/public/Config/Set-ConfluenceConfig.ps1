#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
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

    # Guard the boundary before persisting so a caller cannot corrupt the stored configuration:
    # 'ID' is the reserved context key that identifies the config record itself, and 'PerPage'
    # is used verbatim as the v2 'limit' query value, so it must be a positive integer.
    if ($Name -eq 'ID') {
        throw "The configuration key 'ID' is reserved for internal use and cannot be set."
    }
    if ($Name -eq 'PerPage') {
        $perPage = 0
        if (-not [int]::TryParse([string]$Value, [ref]$perPage) -or $perPage -lt 1) {
            throw "PerPage must be a positive integer; received '$Value'."
        }
        $Value = $perPage
    }

    if ($PSCmdlet.ShouldProcess("Confluence config '$Name'", 'Set')) {
        $script:Confluence.Config[$Name] = $Value
        $null = Set-Context -ID $script:Confluence.DefaultConfig.ID -Context $script:Confluence.Config -Vault $script:Confluence.ContextVault
    }
}
