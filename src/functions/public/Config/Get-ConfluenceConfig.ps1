#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluenceConfig {
    <#
        .SYNOPSIS
        Get the Confluence module configuration.

        .DESCRIPTION
        Returns the whole configuration hashtable, or the value of a single
        named configuration item.

        .EXAMPLE
        ```powershell
        Get-ConfluenceConfig -Name 'DefaultContext'
        ```

        Gets the DefaultContext value from the module configuration.

        .LINK
        https://psmodule.io/Confluence/Functions/Config/Get-ConfluenceConfig/
    #>
    [CmdletBinding()]
    param(
        # The configuration item to return. If omitted, the whole config is returned.
        [string]$Name
    )

    Initialize-ConfluenceConfig
    if ([string]::IsNullOrEmpty($Name)) {
        # Return a shallow copy so callers cannot mutate the in-memory configuration cache by
        # accident; changes must go through Set-ConfluenceConfig to be persisted. Cloning a small
        # hashtable of scalars is negligible next to the vault I/O the module already performs.
        return $script:Confluence.Config.Clone()
    }
    $script:Confluence.Config[$Name]
}
