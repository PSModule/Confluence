class ConfluenceSpacePermission : ConfluenceEntity {
    [string] $Id
    [string] $PrincipalType
    [string] $PrincipalName
    [string] $Operation
    [string] $TargetType

    ConfluenceSpacePermission([object] $source) {
        $this.Raw = $source
        $this.Id = [ConfluenceEntity]::GetString($source, 'id')
        $this.PrincipalType = [ConfluenceEntity]::GetString($source.principal, 'type')
        $this.PrincipalName = [ConfluenceEntity]::GetString($source.principal, 'name')
        $this.Operation = [ConfluenceEntity]::GetString($source.operation, 'operation')
        $this.TargetType = [ConfluenceEntity]::GetString($source.operation, 'targetType')
    }
}
