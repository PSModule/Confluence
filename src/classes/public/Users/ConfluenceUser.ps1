class ConfluenceUser : ConfluenceEntity {
    [string] $AccountId
    [string] $DisplayName
    [string] $Email
    [string] $PublicName

    ConfluenceUser([object] $source) {
        $this.Raw = $source
        $this.AccountId = [ConfluenceEntity]::GetString($source, 'accountId')
        $this.DisplayName = [ConfluenceEntity]::GetString($source, 'displayName')
        $this.Email = [ConfluenceEntity]::GetString($source, 'email')
        $this.PublicName = [ConfluenceEntity]::GetString($source, 'publicName')
    }
}
