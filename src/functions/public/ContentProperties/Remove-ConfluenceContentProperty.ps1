function Remove-ConfluenceContentProperty {
    <#
    .SYNOPSIS
        Delete a content property from a page (read:page and write:page).
    .DESCRIPTION
        Deletes a content property by its id. In v2, page content properties are
        governed by the page's own scope (read:page and write:page).
    .EXAMPLE
        Remove-ConfluenceContentProperty -PageId '12345' -PropertyId '98765'
    .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-content-properties/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The page id.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The content-property id.
        [Parameter(Mandatory)]
        [string]$PropertyId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($PSCmdlet.ShouldProcess("$PageId/$PropertyId", 'Delete content property')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId/properties/$PropertyId" -Method 'DELETE' -Context $Context
    }
}
