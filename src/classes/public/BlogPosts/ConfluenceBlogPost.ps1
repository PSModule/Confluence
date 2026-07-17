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
