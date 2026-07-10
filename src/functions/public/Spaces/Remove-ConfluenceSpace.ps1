#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Remove-ConfluenceSpace {
    <#
        .SYNOPSIS
        Permanently delete a Confluence space (delete:space and read:content.metadata).

        .DESCRIPTION
        Permanently deletes a space and all of its content - the space is NOT sent
        to the trash and cannot be restored. The call is asynchronous: Confluence
        returns HTTP 202 with a long-running task descriptor. Deleting a space is a
        v1-only operation reached over the API gateway; it needs the granular
        delete:space scope (Atlassian also requires read:content.metadata on this
        endpoint) plus Admin permission on the space. Because deletion is
        irreversible, confirm the key belongs to a space you own before calling it.

        .EXAMPLE
        ```powershell
        Remove-ConfluenceSpace -Key 'DOCS'
        ```

        Permanently deletes the 'DOCS' space and returns the long-running task descriptor.

        .LINK
        https://psmodule.io/Confluence/Functions/Spaces/Remove-ConfluenceSpace/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v1/api-group-space/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The key of the space to delete.
        [Parameter(Mandatory)]
        [string]$Key,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($PSCmdlet.ShouldProcess($Key, 'Permanently delete Confluence space')) {
        Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/rest/api/space/$Key" -Method 'DELETE' -Context $Context
    }
}
