#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '8.1.6' }

<#
    Confluence — a small, generalized PowerShell client for the Atlassian
    Confluence Cloud REST API v2.

    Design:
    - Credential profiles and module configuration are persisted with the
      PSModule 'Context' module (following the PSModule/GitHub pattern).
    - Every resource function (pages, folders, comments, labels, content
      properties, attachments, restrictions, spaces) is a thin wrapper over the
      single generic 'Invoke-ConfluenceRestMethod' function.
    - The service-account token is a scoped, granular (v2-aligned) Atlassian
      token, so calls go to the API-gateway host on the '/wiki/api/v2' path.
      A few v1 endpoints that Atlassian has mapped to granular scopes (labels,
      restrictions, attachments, current user) are also reachable; most v1
      endpoints are not.

    Documentation style: parameter descriptions live inline as comments directly
    above each parameter (docs close to code). Comment-based help blocks carry
    only .SYNOPSIS / .DESCRIPTION / .EXAMPLE / .LINK; PowerShell sources the
    per-parameter help from the inline comments.

    References (used to determine the OAuth 2.0 scope each function requires):
    - REST API v2 reference:      https://developer.atlassian.com/cloud/confluence/rest/v2/intro/
    - REST API v2 OpenAPI spec:   https://dac-static.atlassian.com/cloud/confluence/openapi-v2.v3.json
    - REST API v1 reference:      https://developer.atlassian.com/cloud/confluence/rest/v1/intro/
    - REST API v1 (Swagger) spec: https://dac-static.atlassian.com/cloud/confluence/swagger.v3.json
    - OAuth 2.0 scopes:           https://developer.atlassian.com/cloud/confluence/scopes-for-oauth-2-3LO-and-forge-apps/

    Each public function's comment-based help names the granular scope(s) it needs
    (in the .SYNOPSIS) and links the matching reference page (.LINK). Note that in
    v2 many child resources are governed by the PARENT's scope: listing a page's
    labels, versions, children, or content properties requires read:page (not
    read:label / read:content.property), and space permissions/properties require
    read:space (not read:space.permission).
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains long links.')]
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
