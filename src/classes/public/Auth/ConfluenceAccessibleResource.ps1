class ConfluenceAccessibleResource : ConfluenceEntity {
    [string] $Id
    [string] $Url
    [string] $Name
    [string[]] $Scopes

    ConfluenceAccessibleResource([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.Url = [ConfluenceEntity]::GetString($source, 'url')
        $this.Name = [ConfluenceEntity]::GetString($source, 'name')
        $this.Scopes = @($source.scopes | ForEach-Object { [string] $_ })
    }
}
