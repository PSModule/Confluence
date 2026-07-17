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
