# Confluence

Confluence is a PowerShell module for interacting with the Atlassian Confluence Cloud REST API, both interactively and in automation.

It exposes pages, blog posts, folders, spaces, comments, labels, content properties, attachments, restrictions and more as PowerShell commands.
Every command is a thin wrapper over a single generic REST entry point (`Invoke-ConfluenceRestMethod`). Credentials and module configuration
are stored with the [Context](https://github.com/PSModule/Context) module, so you connect once and reuse the profile across sessions.

## Installation

Install the module from the PowerShell Gallery:

```powershell
Install-PSResource -Name Confluence
Import-Module -Name Confluence
```

## Usage

Connect with a scoped Atlassian API token, then call the resource commands. The token is kept as a `SecureString` in the Context vault.

```powershell
# Connect and store a reusable, named credential profile
$token = Read-Host -AsSecureString   # a scoped Atlassian API token
Connect-Confluence -ApiBaseUri 'https://api.atlassian.com/ex/confluence/<cloudId>' -Username 'you@example.com' -Token $token -SpaceKey 'DOCS'

# Work with content
$space = Get-ConfluenceSpace -Key 'DOCS'
$page = New-ConfluencePage -SpaceId $space.id -Title 'Release notes' -Body '<p>Hello</p>'
Set-ConfluencePage -PageId $page.id -Body '<p>Updated</p>'
Get-ConfluencePageChild -PageId $page.id
```

See the [examples](examples) folder for more, including managing contexts and pages.

The service-account token must be granted the module's required Confluence scopes — see [SCOPES.md](SCOPES.md).

## Documentation

Documentation is published at [psmodule.io/Confluence](https://psmodule.io/Confluence/).

Use PowerShell help and command discovery for module details:

```powershell
Get-Command -Module Confluence
Get-Help New-ConfluencePage -Examples
```

## Contributing

Issues and pull requests are welcome. Please use the repository issue tracker to report bugs, request features, or discuss improvements.
