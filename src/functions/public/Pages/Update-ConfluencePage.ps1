#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Update-ConfluencePage {
    <#
        .SYNOPSIS
        Update a Confluence page (read:page and write:page).

        .DESCRIPTION
        Updates the title and/or body of a page, automatically incrementing the
        version number. Unspecified fields keep their current values. The current
        page is read first (read:page) to preserve unspecified fields and to
        obtain the version number, then written back (write:page).

        .EXAMPLE
        ```powershell
        Update-ConfluencePage -PageId '12345' -Body '<p>Updated</p>'
        ```

        Updates the body of page 12345, incrementing its version.

        .LINK
        https://psmodule.io/Confluence/Functions/Pages/Update-ConfluencePage/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-page/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The page ID to update.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The new title. Defaults to the existing title.
        [string]$Title,

        # The new body, as a string in the chosen representation. For 'atlas_doc_format' pass the
        # ADF document serialized as a JSON string (the v2 API stores body.value as a string for
        # every representation). Defaults to the existing body.
        [string]$Body,

        # The body representation. Defaults to 'storage'.
        [ValidateSet('storage', 'atlas_doc_format', 'wiki')]
        [string]$Representation = 'storage',

        # The page status. Defaults to the page's current status.
        [string]$Status,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $current = Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId" -Query @{ 'body-format' = $Representation } -Context $Context

    $newTitle = if ($PSBoundParameters.ContainsKey('Title')) { $Title } else { $current.title }
    $newBody = if ($PSBoundParameters.ContainsKey('Body')) { $Body } else { $current.body.$Representation.value }
    $newStatus = if ($PSBoundParameters.ContainsKey('Status')) { $Status } else { $current.status }

    $payload = @{
        id      = $PageId
        status  = $newStatus
        title   = $newTitle
        version = @{
            number = [int]$current.version.number + 1
        }
        body    = @{
            representation = $Representation
            value          = $newBody
        }
    }

    if ($PSCmdlet.ShouldProcess($PageId, 'Update Confluence page')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId" -Method 'PUT' -Body $payload -Context $Context
    }
}
