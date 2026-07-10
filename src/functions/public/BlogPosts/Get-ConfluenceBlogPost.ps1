#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Get-ConfluenceBlogPost {
    <#
        .SYNOPSIS
        Get blog posts (read:blogpost).

        .DESCRIPTION
        Returns a single blog post by id, the blog posts in a space, or all blog
        posts across the site, following pagination.

        .EXAMPLE
        ```powershell
        Get-ConfluenceBlogPost -SpaceId '123456'
        ```

        Lists the blog posts in the space with ID 123456.

        .LINK
        https://psmodule.io/Confluence/Functions/BlogPosts/Get-ConfluenceBlogPost/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-blog-post/
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        # A single blog post id to return.
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$BlogPostId,

        # List blog posts in this space id. Omit to list across the whole site.
        [Parameter(ParameterSetName = 'List')]
        [string]$SpaceId,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($PSCmdlet.ParameterSetName -eq 'ById') {
        return Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/blogposts/$BlogPostId" -Context $Context
    }
    if (-not [string]::IsNullOrEmpty($SpaceId)) {
        return Invoke-ConfluenceRestMethod -ApiEndpoint "/wiki/api/v2/spaces/$SpaceId/blogposts" -All -Context $Context
    }
    Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/blogposts' -All -Context $Context
}
