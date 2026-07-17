$classFiles = @(
    'Base/ConfluenceEntity.ps1'
    'Spaces/ConfluenceSpace.ps1'
    'Spaces/ConfluenceSpacePermission.ps1'
    'Spaces/ConfluenceSpaceProperty.ps1'
    'Pages/ConfluencePage.ps1'
    'Pages/ConfluencePageVersion.ps1'
    'Folders/ConfluenceFolder.ps1'
    'Comments/ConfluenceComment.ps1'
    'Labels/ConfluenceLabel.ps1'
    'ContentProperties/ConfluenceContentProperty.ps1'
    'Attachments/ConfluenceAttachment.ps1'
    'Restrictions/ConfluenceRestriction.ps1'
    'BlogPosts/ConfluenceBlogPost.ps1'
    'Users/ConfluenceUser.ps1'
    'Site/ConfluenceSiteInfo.ps1'
    'Auth/ConfluenceAccessibleResource.ps1'
)

foreach ($classFile in $classFiles) {
    . (Join-Path -Path $PSScriptRoot -ChildPath (Join-Path -Path '../../classes/public' -ChildPath $classFile))
}

$script:Confluence = [pscustomobject]@{
    ContextVault  = 'PSModule.Confluence'
    # The API-gateway base is https://api.atlassian.com/ex/confluence/<cloudId>. These are the two
    # Confluence API families that hang off it; the map keeps the version prefixes in one place.
    #   v2 -> <base>/wiki/api/v2/...   (e.g. /wiki/api/v2/spaces)
    #   v1 -> <base>/wiki/rest/api/... (e.g. /wiki/rest/api/content)
    ApiPaths      = @{
        v1 = '/wiki/rest/api'
        v2 = '/wiki/api/v2'
    }
    DefaultConfig = @{
        ID             = 'Module'
        DefaultContext = ''
        PerPage        = 100
    }
    Config        = $null
}

