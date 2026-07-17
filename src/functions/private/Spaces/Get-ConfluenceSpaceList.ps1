function Get-ConfluenceSpaceListEndpoint {
    [CmdletBinding()]
    param(
        [object]$Context
    )

    Invoke-ConfluenceRestMethod -ApiVersion 'v2' -ApiEndpoint 'spaces' -All -Context $Context
}
