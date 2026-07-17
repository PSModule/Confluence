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
