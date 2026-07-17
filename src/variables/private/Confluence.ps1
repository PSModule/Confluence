class ConfluenceEntity {
    [object] $Raw

    hidden static [string] GetString([object] $source, [string] $propertyName) {
        if ($null -eq $source) {
            return ''
        }

        $property = $source.PSObject.Properties[$propertyName]
        if ($null -eq $property -or $null -eq $property.Value) {
            return ''
        }

        return [string] $property.Value
    }
}

class ConfluenceSpace : ConfluenceEntity {
    [string] $Id
    [string] $Key
    [string] $Name
    [string] $Type
    [string] $Status
    [string] $HomepageId

    ConfluenceSpace([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.Key = [ConfluenceEntity]::GetString($source, 'key')
        $this.Name = [ConfluenceEntity]::GetString($source, 'name')
        $this.Type = [ConfluenceEntity]::GetString($source, 'type')
        $this.Status = [ConfluenceEntity]::GetString($source, 'status')
        $this.HomepageId = [ConfluenceEntity]::GetString($source, 'homepageId')
    }
}

class ConfluenceSpacePermission : ConfluenceEntity {
    [string] $Id
    [string] $PrincipalType
    [string] $PrincipalName
    [string] $Operation
    [string] $TargetType

    ConfluenceSpacePermission([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.PrincipalType = [ConfluenceEntity]::GetString($source.principal, 'type')
        $this.PrincipalName = [ConfluenceEntity]::GetString($source.principal, 'name')
        $this.Operation = [ConfluenceEntity]::GetString($source.operation, 'operation')
        $this.TargetType = [ConfluenceEntity]::GetString($source.operation, 'targetType')
    }
}

class ConfluenceSpaceProperty : ConfluenceEntity {
    [string] $Id
    [string] $Key
    [string] $Value

    ConfluenceSpaceProperty([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.Key = [ConfluenceEntity]::GetString($source, 'key')
        $this.Value = [ConfluenceEntity]::GetString($source, 'value')
    }
}

class ConfluencePage : ConfluenceEntity {
    [string] $Id
    [string] $Title
    [string] $Status
    [string] $SpaceId
    [string] $ParentId

    ConfluencePage([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.Title = [ConfluenceEntity]::GetString($source, 'title')
        $this.Status = [ConfluenceEntity]::GetString($source, 'status')
        $this.SpaceId = [ConfluenceEntity]::GetString($source, 'spaceId')
        $this.ParentId = [ConfluenceEntity]::GetString($source, 'parentId')
    }
}

class ConfluencePageVersion : ConfluenceEntity {
    [string] $Number
    [string] $AuthorId
    [string] $CreatedAt

    ConfluencePageVersion([object] $source) {
        $this.Raw = $source
        $this.Number = [ConfluenceEntity]::GetString($source, 'number')
        $this.AuthorId = [ConfluenceEntity]::GetString($source.authorId, 'id')
        $this.CreatedAt = [ConfluenceEntity]::GetString($source, 'createdAt')
    }
}

class ConfluenceFolder : ConfluenceEntity {
    [string] $Id
    [string] $Title
    [string] $ParentId

    ConfluenceFolder([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.Title = [ConfluenceEntity]::GetString($source, 'title')
        $this.ParentId = [ConfluenceEntity]::GetString($source, 'parentId')
    }
}

class ConfluenceComment : ConfluenceEntity {
    [string] $Id
    [string] $Status
    [string] $PageId

    ConfluenceComment([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.Status = [ConfluenceEntity]::GetString($source, 'status')
        $this.PageId = [ConfluenceEntity]::GetString($source, 'pageId')
    }
}

class ConfluenceLabel : ConfluenceEntity {
    [string] $Name
    [string] $Prefix
    [string] $Id

    ConfluenceLabel([object] $source) {
        $this.Raw = $source
        $this.Name = [ConfluenceEntity]::GetString($source, 'name')
        $this.Prefix = [ConfluenceEntity]::GetString($source, 'prefix')
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
    }
}

class ConfluenceContentProperty : ConfluenceEntity {
    [string] $Id
    [string] $Key
    [string] $Version

    ConfluenceContentProperty([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.Key = [ConfluenceEntity]::GetString($source, 'key')
        $this.Version = [ConfluenceEntity]::GetString($source.version, 'number')
    }
}

class ConfluenceAttachment : ConfluenceEntity {
    [string] $Id
    [string] $Title
    [string] $MediaType
    [string] $FileSize

    ConfluenceAttachment([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.Title = [ConfluenceEntity]::GetString($source, 'title')
        $this.MediaType = [ConfluenceEntity]::GetString($source, 'mediaType')
        $this.FileSize = [ConfluenceEntity]::GetString($source.fileSize, 'value')
    }
}

class ConfluenceRestriction : ConfluenceEntity {
    [string] $Operation
    [string] $RestrictionsUserCount
    [string] $RestrictionsGroupCount

    ConfluenceRestriction([object] $source) {
        $this.Raw = $source
        $this.Operation = [ConfluenceEntity]::GetString($source, 'operation')
        $this.RestrictionsUserCount = [ConfluenceEntity]::GetString($source.restrictions.user, 'size')
        $this.RestrictionsGroupCount = [ConfluenceEntity]::GetString($source.restrictions.group, 'size')
    }
}

class ConfluenceBlogPost : ConfluenceEntity {
    [string] $Id
    [string] $Title
    [string] $Status
    [string] $SpaceId

    ConfluenceBlogPost([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.Title = [ConfluenceEntity]::GetString($source, 'title')
        $this.Status = [ConfluenceEntity]::GetString($source, 'status')
        $this.SpaceId = [ConfluenceEntity]::GetString($source, 'spaceId')
    }
}

class ConfluenceUser : ConfluenceEntity {
    [string] $AccountId
    [string] $DisplayName
    [string] $Email
    [string] $PublicName

    ConfluenceUser([object] $source) {
        $this.Raw = $source
        $this.AccountId = [ConfluenceEntity]::GetString($source, 'accountId')
        $this.DisplayName = [ConfluenceEntity]::GetString($source, 'displayName')
        $this.Email = [ConfluenceEntity]::GetString($source, 'email')
        $this.PublicName = [ConfluenceEntity]::GetString($source, 'publicName')
    }
}

class ConfluenceSiteInfo : ConfluenceEntity {
    [string] $CloudId
    [string] $ApiBaseUri
    [string] $SiteUrl

    ConfluenceSiteInfo([object] $source) {
        $this.Raw = $source
        $this.CloudId = [ConfluenceEntity]::GetString($source, 'CloudId')
        $this.ApiBaseUri = [ConfluenceEntity]::GetString($source, 'ApiBaseUri')
        $this.SiteUrl = [ConfluenceEntity]::GetString($source, 'SiteUrl')
    }
}

class ConfluenceAccessibleResource : ConfluenceEntity {
    [string] $Id
    [string] $Url
    [string] $Name
    [string[]] $Scopes

    ConfluenceAccessibleResource([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.Url = [ConfluenceEntity]::GetString($source, 'url')
        $this.Name = [ConfluenceEntity]::GetString($source, 'name')
        $this.Scopes = @($source.scopes | ForEach-Object { [string] $_ })
    }
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

$displayPropertySets = @{
    ConfluenceSpace = @('Key', 'Name', 'Id', 'Status', 'Type')
    ConfluenceSpacePermission = @('PrincipalType', 'PrincipalName', 'Operation', 'TargetType')
    ConfluenceSpaceProperty = @('Key', 'Value', 'Id')
    ConfluencePage = @('Title', 'Id', 'Status', 'SpaceId')
    ConfluencePageVersion = @('Number', 'CreatedAt', 'AuthorId')
    ConfluenceFolder = @('Title', 'Id', 'ParentId')
    ConfluenceComment = @('Id', 'Status', 'PageId')
    ConfluenceLabel = @('Name', 'Prefix', 'Id')
    ConfluenceContentProperty = @('Key', 'Version', 'Id')
    ConfluenceAttachment = @('Title', 'MediaType', 'FileSize', 'Id')
    ConfluenceRestriction = @('Operation', 'RestrictionsUserCount', 'RestrictionsGroupCount')
    ConfluenceBlogPost = @('Title', 'Id', 'Status', 'SpaceId')
    ConfluenceUser = @('DisplayName', 'PublicName', 'Email', 'AccountId')
    ConfluenceSiteInfo = @('CloudId', 'SiteUrl', 'ApiBaseUri')
    ConfluenceAccessibleResource = @('Name', 'Url', 'Id', 'Scopes')
}

foreach ($entry in $displayPropertySets.GetEnumerator()) {
    Update-TypeData -TypeName $entry.Key -DefaultDisplayPropertySet $entry.Value -Force
}
