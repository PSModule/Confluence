function Resolve-ConfluenceToken {
    <#
    .SYNOPSIS
        Return the plain-text API token from a SecureString or string.
    .DESCRIPTION
        The token is stored as a SecureString in the credential context; this
        converts it to the plain text needed to build the Basic auth header.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The token as a SecureString or a plain string.
        [Parameter(Mandatory)]
        [object]$Token
    )

    if ($Token -is [System.Security.SecureString]) {
        return [System.Net.NetworkCredential]::new('', $Token).Password
    }
    return [string]$Token
}
