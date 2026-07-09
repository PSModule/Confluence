function Remove-ConfluenceLabel {
    <#
        .SYNOPSIS
        Remove a label from a page (write:label).

        .DESCRIPTION
        Removes a label from a page via the v1 content endpoint.

        .EXAMPLE
        ```powershell
        Remove-ConfluenceLabel -PageId '12345' -Label 'docs'
        ```

        Removes the 'docs' label from page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Labels/Remove-ConfluenceLabel/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v1/api-group-content-labels/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The page (content) id.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The label name to remove.
        [Parameter(Mandatory)]
        [string]$Label,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($PSCmdlet.ShouldProcess($PageId, "Remove label: $Label")) {
        Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/rest/api/content/$PageId/label" -Method 'DELETE' -Query @{ name = $Label } -Context $Context
    }
}
