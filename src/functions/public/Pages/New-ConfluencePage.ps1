#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function New-ConfluencePage {
    <#
        .SYNOPSIS
        Create a Confluence page (write:page).

        .DESCRIPTION
        Creates a page in a space, optionally beneath a parent page. A page with
        no parent is created under the space home page.

        .EXAMPLE
        ```powershell
        New-ConfluencePage -SpaceId $spaceId -Title 'Docs' -Body '<p>Hello</p>'
        ```

        Creates a page titled 'Docs' in the given space.

        .LINK
        https://psmodule.io/Confluence/Functions/Pages/New-ConfluencePage/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-page/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The id of the space to create the page in.
        [Parameter(Mandatory)]
        [string]$SpaceId,

        # The page title (must be unique within the space).
        [Parameter(Mandatory)]
        [string]$Title,

        # The id of the parent page. Omit to create a top-level page.
        [string]$ParentId,

        # The page body in the chosen representation. Defaults to empty.
        [string]$Body = '',

        # The body representation. Defaults to 'storage'.
        [ValidateSet('storage', 'atlas_doc_format', 'wiki')]
        [string]$Representation = 'storage',

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    $payload = @{
        spaceId = $SpaceId
        status  = 'current'
        title   = $Title
        body    = @{
            representation = $Representation
            value          = $Body
        }
    }
    if (-not [string]::IsNullOrEmpty($ParentId)) {
        $payload['parentId'] = $ParentId
    }

    if ($PSCmdlet.ShouldProcess($Title, 'Create Confluence page')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/pages' -Method 'POST' -Body $payload -Context $Context
    }
}
