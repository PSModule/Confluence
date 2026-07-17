class ConfluenceSiteInfo : ConfluenceEntity {
    [string] $CloudId
    [string] $ApiBaseUri
    [string] $SiteUrl

    ConfluenceSiteInfo([object] $source) {
        $this.Raw = $source
        $this.CloudId = [ConfluenceEntity]::GetString($source, 'CloudId')
        $this.ApiBaseUri = [ConfluenceEntity]::GetString($source, 'ApiBaseUri')
        $this.SiteUrl = [ConfluenceEntity]::GetString($source, 'SiteUrl')
    }
}
