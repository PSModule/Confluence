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
