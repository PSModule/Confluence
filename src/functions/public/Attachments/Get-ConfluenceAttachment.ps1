function Get-ConfluenceAttachment {
    <#
        .SYNOPSIS
        Get page attachments (read:attachment).

        .DESCRIPTION
        Lists the attachments on a page, or returns a single attachment by id.

        .EXAMPLE
        ```powershell
        Get-ConfluenceAttachment -PageId '12345'
        ```

        Lists the attachments on page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Attachments/Get-ConfluenceAttachment/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-attachment/
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByPage')]
    param(
        # The page id whose attachments are listed.
        [Parameter(Mandatory, ParameterSetName = 'ByPage')]
        [string]$PageId,

        # A single attachment id to return.
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$AttachmentId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($PSCmdlet.ParameterSetName -eq 'ById') {
        return Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/attachments/$AttachmentId" -Context $Context
    }

    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/pages/$PageId/attachments" -All -Context $Context
}
