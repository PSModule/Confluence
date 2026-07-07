function Add-ConfluenceLabel {
    <#
        .SYNOPSIS
        Add one or more labels to a page (read:label and write:label).

        .DESCRIPTION
        Adds labels to a page. Confluence exposes label creation only on the v1
        content endpoint (/wiki/rest/api/content/{id}/label), which the granular
        read:label and write:label scopes authorise.

        .EXAMPLE
        ```powershell
        Add-ConfluenceLabel -PageId '12345' -Label 'docs', 'published'
        ```

        Adds the 'docs' and 'published' labels to page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Labels/Add-ConfluenceLabel/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v1/api-group-content-labels/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The page (content) id to label.
        [Parameter(Mandatory)]
        [string]$PageId,

        # One or more label names to add.
        [Parameter(Mandatory)]
        [string[]]$Label,

        # The label prefix. Defaults to 'global'.
        [string]$Prefix = 'global',

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $payload = foreach ($name in $Label) {
        @{
            prefix = $Prefix
            name   = $name
        }
    }
    # @(...) forces an array (a single label is otherwise a scalar) and -InputObject
    # avoids the pipeline, so the v1 label endpoint always receives a JSON array.
    $json = ConvertTo-Json -InputObject @($payload) -Depth 5 -Compress

    if ($PSCmdlet.ShouldProcess($PageId, "Add label(s): $($Label -join ', ')")) {
        Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/rest/api/content/$PageId/label" -Method 'POST' -Body $json -Context $Context
    }
}
