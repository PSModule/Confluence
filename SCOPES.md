# Required Atlassian scopes

`Confluence` authenticates with a **scoped** Atlassian API token (the `ATSTT…`
prefix) used as HTTP Basic authentication (`<service-account-email>:<token>`)
against the API-gateway host `https://api.atlassian.com/ex/confluence/<cloudId>`.

When you create the token for the service account, select **granular** Confluence
scopes (not the classic `*-confluence-*` scopes). The list below is the full set
the module's commands use today — use it when generating or rotating a token.

## Scope list

```text
read:space:confluence
read:space.permission:confluence
read:space.property:confluence
read:page:confluence
read:blogpost:confluence
read:folder:confluence
read:attachment:confluence
read:comment:confluence
read:label:confluence
read:content.property:confluence
read:hierarchical-content:confluence
read:content-details:confluence
write:page:confluence
write:folder:confluence
write:attachment:confluence
write:comment:confluence
write:label:confluence
write:content.property:confluence
delete:page:confluence
delete:folder:confluence
delete:attachment:confluence
delete:comment:confluence
```

That is 22 scopes: 12 read, 6 write, 4 delete.

## What each scope is for

| Scope | Used by |
| --- | --- |
| `read:space:confluence` | `Get-ConfluenceSpace`, `Get-ConfluenceSiteInfo` |
| `read:space.permission:confluence` | `Get-ConfluenceSpacePermission` |
| `read:space.property:confluence` | `Get-ConfluenceSpaceProperty` |
| `read:page:confluence` | `Get-ConfluencePage`, `Get-ConfluencePageChild`, `Get-ConfluencePageVersion`, `Set-ConfluencePage` (reads before updating) |
| `read:blogpost:confluence` | `Get-ConfluenceBlogPost` |
| `read:folder:confluence` | `Get-ConfluenceFolder` |
| `read:attachment:confluence` | `Get-ConfluenceAttachment` |
| `read:comment:confluence` | `Get-ConfluenceComment` |
| `read:label:confluence` | `Get-ConfluenceLabel` |
| `read:content.property:confluence` | `Get-ConfluenceContentProperty` |
| `read:hierarchical-content:confluence` | `Get-ConfluenceDescendant` |
| `read:content-details:confluence` | `Get-ConfluenceRestriction`, `Get-ConfluenceCurrentUser`, `Add-ConfluenceAttachment` (upload) |
| `write:page:confluence` | `New-ConfluencePage`, `Set-ConfluencePage` |
| `write:folder:confluence` | `New-ConfluenceFolder` |
| `write:attachment:confluence` | `Add-ConfluenceAttachment` |
| `write:comment:confluence` | `Add-ConfluenceComment` |
| `write:label:confluence` | `Add-ConfluenceLabel`, `Remove-ConfluenceLabel` |
| `write:content.property:confluence` | `Set-ConfluenceContentProperty`, `Remove-ConfluenceContentProperty` |
| `delete:page:confluence` | `Remove-ConfluencePage` |
| `delete:folder:confluence` | `Remove-ConfluenceFolder` |
| `delete:attachment:confluence` | `Remove-ConfluenceAttachment` |
| `delete:comment:confluence` | `Remove-ConfluenceComment` |

## Notes

- Scopes are only an **API ceiling**. Effective access is still bounded by the
  service account's Confluence **permissions** (global and per-space), so grant it
  the matching permissions on the spaces you target.
- This set contains **no space-administration** scope: the token can read space
  permissions and properties but cannot change space settings or permissions.
- A few commands reach v1 endpoints that Atlassian maps to these granular scopes:
  label add/remove (`write:label:confluence`), attachment upload
  (`write:attachment:confluence` plus `read:content-details:confluence`), page
  restriction reads and the current user (`read:content-details:confluence`).
- Atlassian applies a soft cap of roughly 50 scopes per token; this set is well
  under it, leaving room to grow.
- Reference: [Confluence OAuth 2.0 scopes](https://developer.atlassian.com/cloud/confluence/scopes-for-oauth-2-3LO-and-forge-apps/).
