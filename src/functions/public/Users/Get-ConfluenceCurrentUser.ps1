#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluenceCurrentUser {
    <#
        .SYNOPSIS
        Get the current (authenticated) user — Confluence's "me" endpoint (read:content-details).

        .DESCRIPTION
        Returns the account behind the connected token via the Confluence
        current-user endpoint (v1 /wiki/rest/api/user/current), which requires
        read:content-details. The read:user scope only covers the anonymous-user
        and group-membership endpoints, so a token without read:content-details is
        rejected with a scope-check 401.

        .EXAMPLE
        ```powershell
        Get-ConfluenceCurrentUser
        ```

        Returns the account behind the connected token.

        .LINK
        https://psmodule.io/Confluence/Functions/Users/Get-ConfluenceCurrentUser/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v1/api-group-users/
    #>
    [CmdletBinding()]
    param(
        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/rest/api/user/current' -Context $Context
}
