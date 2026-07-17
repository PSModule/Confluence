function Get-ConfluenceSpaceByIdEndpoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Id,

        [object]$Context
    )

    Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/spaces/$Id" -Context $Context
}
