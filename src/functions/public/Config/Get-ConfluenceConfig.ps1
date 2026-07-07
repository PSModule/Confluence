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
        return $script:Confluence.Config
    }
    $script:Confluence.Config[$Name]
}
