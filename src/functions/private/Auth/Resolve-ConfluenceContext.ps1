function Resolve-ConfluenceContext {
    <#
        .SYNOPSIS
        Resolve a context argument into a usable credential-context object.

        .DESCRIPTION
        Accepts a context object/hashtable (returned as-is), a context name
        (looked up in the vault), or nothing (falls back to the default context
        recorded in the module configuration).
    #>
    [CmdletBinding()]
    param(
        # A context object, a context name, or $null for the default context.
        [object]$Context
    )

    if ($null -ne $Context -and $Context -isnot [string]) {
        return $Context
    }

    Initialize-ConfluenceConfig
    $id = if ([string]::IsNullOrEmpty([string]$Context)) { $script:Confluence.Config['DefaultContext'] } else { [string]$Context }

    if ([string]::IsNullOrEmpty($id)) {
        throw 'No Confluence context was specified and no default context is set. Run Connect-Confluence first.'
    }

    $resolved = $null
    try {
        $resolved = Get-Context -ID $id -Vault $script:Confluence.ContextVault -ErrorAction Stop
    } catch {
        $resolved = $null
    }

    if (-not $resolved) {
        throw "Confluence context '$id' was not found in vault '$($script:Confluence.ContextVault)'."
    }
    return $resolved
}
