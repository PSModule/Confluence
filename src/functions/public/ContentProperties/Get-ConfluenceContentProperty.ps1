function Get-ConfluenceContentProperty {
    <#
        .SYNOPSIS
        Get content properties of a page (read:page).

        .DESCRIPTION
        Returns all content properties on a page, or the single property with the
        given key. In v2, a page's content properties are governed by the page's
        own scope (read:page); the read:content.property scope applies to the v1
        property API.

        .EXAMPLE
        ```powershell
        Get-ConfluenceContentProperty -PageId '12345' -Key 'my-prop'
        ```

        Gets the 'my-prop' content property from page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/ContentProperties/Get-ConfluenceContentProperty/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-content-properties/
    #>
    [CmdletBinding()]
    param(
        # The page id.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The property key to return. If omitted, all properties are returned.
        [string]$Key,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $all = Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId/properties" -All -Context $Context
    if ([string]::IsNullOrEmpty($Key)) {
        return $all
    }
    $all | Where-Object { $_.key -eq $Key } | Select-Object -First 1
}
