<#
    .SYNOPSIS
    Create, read, update and remove Confluence pages.

    .DESCRIPTION
    Assumes a default context is already connected (see Connecting.ps1).
#>

# Import the module
Import-Module -Name 'Confluence'

# Resolve the target space
$space = Get-ConfluenceSpace -Key 'DOCS'

# Create a page
$page = New-ConfluencePage -SpaceId $space.id -Title 'Release notes' -Body '<p>First draft</p>'

# Read it back (storage format by default)
Get-ConfluencePage -PageId $page.id

# Update the body (the version number is incremented automatically)
Set-ConfluencePage -PageId $page.id -Body '<p>Updated content</p>'

# Add a child page, then list children and descendants
New-ConfluencePage -SpaceId $space.id -Title 'Details' -ParentId $page.id -Body '<p>Nested</p>'
Get-ConfluencePageChild -PageId $page.id
Get-ConfluenceDescendant -PageId $page.id

# Labels and comments
Add-ConfluenceLabel -PageId $page.id -Label 'release', 'published'
Add-ConfluenceComment -PageId $page.id -Body '<p>Looks good.</p>'

# Remove the whole subtree (moves the pages to trash)
Remove-ConfluencePage -PageId $page.id -Recurse
