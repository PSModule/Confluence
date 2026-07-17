class ConfluenceEntity {
    [object] $Raw

    hidden static [string] GetString([object] $source, [string] $propertyName) {
        if ($null -eq $source) {
            return ''
        }

        $property = $source.PSObject.Properties[$propertyName]
        if ($null -eq $property -or $null -eq $property.Value) {
            return ''
        }

        return [string] $property.Value
    }
}
