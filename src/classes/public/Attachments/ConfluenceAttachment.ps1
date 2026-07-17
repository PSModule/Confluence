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
