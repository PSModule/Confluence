function Add-ConfluenceAttachment {
    <#
        .SYNOPSIS
        Upload an attachment to a page (read:content-details and write:attachment).

        .DESCRIPTION
        Uploads a file as a page attachment. Confluence exposes attachment
        creation only on the v1 content endpoint
        (/wiki/rest/api/content/{id}/child/attachment), which requires BOTH
        read:content-details and write:attachment. A token with write:attachment
        but without read:content-details is rejected with a scope-check 401.

        .EXAMPLE
        ```powershell
        Add-ConfluenceAttachment -PageId '12345' -Path ./diagram.png
        ```

        Uploads diagram.png as an attachment on page 12345.

        .LINK
        https://psmodule.io/Confluence/Functions/Attachments/Add-ConfluenceAttachment/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v1/api-group-content---attachments/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The page (content) id to attach the file to.
        [Parameter(Mandatory)]
        [string]$PageId,

        # The path to the file to upload.
        [Parameter(Mandatory)]
        [string]$Path,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Attachment path is not a file: $Path"
    }
    $file = Get-Item -LiteralPath $Path
    $endpoint = "/wiki/rest/api/content/$PageId/child/attachment"

    if ($PSCmdlet.ShouldProcess($PageId, "Upload attachment: $($file.Name)")) {
        Invoke-ConfluenceRestMethod -ApiEndpoint $endpoint -Method 'PUT' -Form @{ file = $file } -Context $Context
    }
}
