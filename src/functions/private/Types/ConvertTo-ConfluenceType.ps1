function ConvertTo-ConfluenceType {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object] $InputObject,

        [Parameter(Mandatory)]
        [ValidateSet(
            'ConfluenceSpace',
            'ConfluenceSpacePermission',
            'ConfluenceSpaceProperty',
            'ConfluencePage',
            'ConfluencePageVersion',
            'ConfluenceFolder',
            'ConfluenceComment',
            'ConfluenceLabel',
            'ConfluenceContentProperty',
            'ConfluenceAttachment',
            'ConfluenceRestriction',
            'ConfluenceBlogPost',
            'ConfluenceUser',
            'ConfluenceSiteInfo',
            'ConfluenceAccessibleResource'
        )]
        [string] $TypeName
    )

    if ($null -eq $InputObject) {
        return $null
    }

    switch ($TypeName) {
        'ConfluenceSpace' {
            return [ConfluenceSpace]::new($InputObject)
        }
        'ConfluenceSpacePermission' {
            return [ConfluenceSpacePermission]::new($InputObject)
        }
        'ConfluenceSpaceProperty' {
            return [ConfluenceSpaceProperty]::new($InputObject)
        }
        'ConfluencePage' {
            return [ConfluencePage]::new($InputObject)
        }
        'ConfluencePageVersion' {
            return [ConfluencePageVersion]::new($InputObject)
        }
        'ConfluenceFolder' {
            return [ConfluenceFolder]::new($InputObject)
        }
        'ConfluenceComment' {
            return [ConfluenceComment]::new($InputObject)
        }
        'ConfluenceLabel' {
            return [ConfluenceLabel]::new($InputObject)
        }
        'ConfluenceContentProperty' {
            return [ConfluenceContentProperty]::new($InputObject)
        }
        'ConfluenceAttachment' {
            return [ConfluenceAttachment]::new($InputObject)
        }
        'ConfluenceRestriction' {
            return [ConfluenceRestriction]::new($InputObject)
        }
        'ConfluenceBlogPost' {
            return [ConfluenceBlogPost]::new($InputObject)
        }
        'ConfluenceUser' {
            return [ConfluenceUser]::new($InputObject)
        }
        'ConfluenceSiteInfo' {
            return [ConfluenceSiteInfo]::new($InputObject)
        }
        'ConfluenceAccessibleResource' {
            return [ConfluenceAccessibleResource]::new($InputObject)
        }
        default {
            throw "Unsupported Confluence type '$TypeName'."
        }
    }
}
