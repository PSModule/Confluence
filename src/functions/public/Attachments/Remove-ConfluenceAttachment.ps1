function Remove-ConfluenceAttachment {
    <#
        .SYNOPSIS
        Delete an attachment (delete:attachment).

        .DESCRIPTION
        Deletes an attachment by id.

        .EXAMPLE
        ```powershell
        Remove-ConfluenceAttachment -AttachmentId 'att12345'
        ```

        Deletes the attachment with ID att12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Attachments/Remove-ConfluenceAttachment/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-attachment/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The attachment id.
        [Parameter(Mandatory)]
        [string]$AttachmentId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($PSCmdlet.ShouldProcess($AttachmentId, 'Delete attachment')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/attachments/$AttachmentId" -Method 'DELETE' -Context $Context
    }
}
