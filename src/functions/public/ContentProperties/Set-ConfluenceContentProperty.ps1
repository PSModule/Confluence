function Set-ConfluenceContentProperty {
    <#
        .SYNOPSIS
        Create or update a content property on a page (read:page and write:page).

        .DESCRIPTION
        Creates the property if it does not exist, or updates it (incrementing
        its version) if it does. In v2, page content properties are governed by
        the page's own scope: reading requires read:page and writing requires
        write:page.

        .EXAMPLE
        ```powershell
        Set-ConfluenceContentProperty -PageId '12345' -Key 'owner' -Value @{ team = 'ai' }
        ```

        Creates or updates the 'owner' content property on page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/ContentProperties/Set-ConfluenceContentProperty/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-content-properties/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The page id.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The property key.
        [Parameter(Mandatory)]
        [string]$Key,

        # The property value (any JSON-serializable object).
        [Parameter(Mandatory)]
        [object]$Value,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $existing = Get-ConfluenceContentProperty -PageId $PageId -Key $Key -Context $Context

    if ($existing) {
        $payload = @{
            key     = $Key
            value   = $Value
            version = @{
                number = [int]$existing.version.number + 1
            }
        }
        $endpoint = "/wiki/api/v2/pages/$PageId/properties/$($existing.id)"
        if ($PSCmdlet.ShouldProcess("$PageId/$Key", 'Update content property')) {
            Invoke-ConfluenceRestMethod -ApiEndpoint $endpoint -Method 'PUT' -Body $payload -Context $Context
        }
    } else {
        $payload = @{
            key   = $Key
            value = $Value
        }
        if ($PSCmdlet.ShouldProcess("$PageId/$Key", 'Create content property')) {
            Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId/properties" -Method 'POST' -Body $payload -Context $Context
        }
    }
}
