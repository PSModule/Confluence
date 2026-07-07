function Get-ConfluenceConfig {
    <#
    .SYNOPSIS
        Get the Confluence module configuration.
    .DESCRIPTION
        Returns the whole configuration hashtable, or the value of a single
        named configuration item.
    .EXAMPLE
        Get-ConfluenceConfig -Name 'DefaultContext'
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
