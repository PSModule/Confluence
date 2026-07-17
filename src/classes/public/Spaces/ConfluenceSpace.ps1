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
