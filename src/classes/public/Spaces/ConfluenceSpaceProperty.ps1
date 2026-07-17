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
