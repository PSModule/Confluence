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
