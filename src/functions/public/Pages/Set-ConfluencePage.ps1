function Set-ConfluencePage {
    <#
    .SYNOPSIS
        Update a Confluence page (read:page and write:page).
    .DESCRIPTION
        Updates the title and/or body of a page, automatically incrementing the
        version number. Unspecified fields keep their current values. The current
        page is read first (read:page) to preserve unspecified fields and to
        obtain the version number, then written back (write:page).
    .EXAMPLE
        Set-ConfluencePage -PageId '12345' -Body '<p>Updated</p>'
    .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-page/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The page id to update.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The new title. Defaults to the existing title.
        [string]$Title,

        # The new body. Defaults to the existing body.
        [string]$Body,

        # The body representation. Defaults to 'storage'.
        [ValidateSet('storage', 'atlas_doc_format', 'wiki')]
        [string]$Representation = 'storage',

        # The page status. Defaults to 'current'.
        [string]$Status = 'current',

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $current = Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId" -Query @{ 'body-format' = $Representation } -Context $Context

    $newTitle = if ($PSBoundParameters.ContainsKey('Title')) { $Title } else { $current.title }
    $newBody = if ($PSBoundParameters.ContainsKey('Body')) { $Body } else { $current.body.$Representation.value }

    $payload = @{
        id      = $PageId
        status  = $Status
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
