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
