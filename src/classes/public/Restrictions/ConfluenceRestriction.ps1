class ConfluenceRestriction : ConfluenceEntity {
    [string] $Operation
    [string] $RestrictionsUserCount
    [string] $RestrictionsGroupCount

    ConfluenceRestriction([object] $source) {
        $this.Raw = $source
        $this.Operation = [ConfluenceEntity]::GetString($source, 'operation')
        $this.RestrictionsUserCount = [ConfluenceEntity]::GetString($source.restrictions.user, 'size')
        $this.RestrictionsGroupCount = [ConfluenceEntity]::GetString($source.restrictions.group, 'size')
    }
}
