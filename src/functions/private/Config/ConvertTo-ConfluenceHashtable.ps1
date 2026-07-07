function ConvertTo-ConfluenceHashtable {
    <#
        .SYNOPSIS
        Convert a PSCustomObject (or hashtable) into a plain hashtable.

        .DESCRIPTION
        Used to turn the stored module-configuration context returned by
        Get-Context into a mutable hashtable.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        # The object to convert.
        [Parameter(Mandatory)]
        [object]$InputObject
    )

    if ($InputObject -is [hashtable]) {
        # Return a shallow clone so callers can mutate the result without altering
        # the source hashtable (e.g. the built-in $script:Confluence.DefaultConfig).
        return $InputObject.Clone()
    }

    $result = @{}
    foreach ($property in $InputObject.PSObject.Properties) {
        $result[$property.Name] = $property.Value
    }
    return $result
}
