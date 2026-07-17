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
