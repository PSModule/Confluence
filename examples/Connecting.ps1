<#
    .SYNOPSIS
    Connect to Confluence and manage credential profiles (contexts).

    .DESCRIPTION
    Confluence stores each connection as a named context in the Context vault.
    The token is kept as a SecureString. One context is the default; any command
    can target a specific context with -Context.
#>

# Import the module
Import-Module -Name 'Confluence'

###
### CONNECTING
###

# Connect with a scoped Atlassian API token and store a reusable default profile.
$token = Read-Host -AsSecureString   # a scoped Atlassian API token
Connect-Confluence -ApiBaseUri 'https://api.atlassian.com/ex/confluence/<cloudId>' -Username 'you@example.com' -Token $token -SpaceKey 'DOCS'

# Store several sites/accounts under explicit names and select per call.
Connect-Confluence -ApiBaseUri 'https://api.atlassian.com/ex/confluence/<cloudId>' -Username 'you@example.com' -Token $token -Name 'sandbox'
Get-ConfluenceSpace -Key 'DOCS' -Context 'sandbox'

###
### CONTEXTS / PROFILES
###

# The default context
Get-ConfluenceContext

# All stored contexts
Get-ConfluenceContext -ListAvailable

###
### MODULE CONFIGURATION
###

# Read and set module configuration (persisted in the same vault).
Get-ConfluenceConfig
Set-ConfluenceConfig -Name 'PerPage' -Value 50

###
### DISCONNECTING
###

Disconnect-Confluence -Name 'sandbox'
