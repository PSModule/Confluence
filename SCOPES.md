# Required Atlassian scopes

`Confluence` authenticates with a **scoped** Atlassian API token (the `ATSTT…`
prefix) used as HTTP Basic authentication (`<service-account-email>:<token>`)
against the API-gateway host `https://api.atlassian.com/ex/confluence/<cloudId>`.

When you create the token for the service account, select **granular** Confluence
scopes (not the classic `*-confluence-*` scopes). Use this document when
generating or rotating a token.

> Note: cmdlet help lists scopes in a shortened form (for example `read:page`),
> omitting the `:confluence` suffix for brevity. The canonical, fully-qualified
> scope strings you grant on the token are the ones in this document (for example
> `read:page:confluence`).

## Configured scopes

The token is currently configured with **48** granular Confluence scopes
(**25 read**, **14 write**, **9 delete**). This is broader than the set the
module's commands use today (see the tables below), leaving headroom for new
commands.

### Read (25)

```text
read:analytics.content:confluence
read:attachment:confluence
read:comment:confluence
read:configuration:confluence
read:content:confluence
read:content-details:confluence
read:content.metadata:confluence
read:content.permission:confluence
read:content.property:confluence
read:content.restriction:confluence
read:custom-content:confluence
read:database:confluence
read:email-address:confluence
read:folder:confluence
read:group:confluence
read:hierarchical-content:confluence
read:label:confluence
read:page:confluence
read:permission:confluence
read:space:confluence
read:space-details:confluence
read:space.permission:confluence
read:space.property:confluence
read:space.setting:confluence
read:user:confluence
```

### Write (14)

```text
write:attachment:confluence
write:audit-log:confluence
write:comment:confluence
write:configuration:confluence
write:content:confluence
write:content.property:confluence
write:content.restriction:confluence
write:custom-content:confluence
write:database:confluence
write:embed:confluence
write:folder:confluence
write:group:confluence
write:label:confluence
write:page:confluence
```

### Delete (9)

```text
delete:attachment:confluence
delete:comment:confluence
delete:content:confluence
delete:custom-content:confluence
delete:database:confluence
delete:embed:confluence
delete:folder:confluence
delete:page:confluence
delete:whiteboard:confluence
```

## Scopes used by the current commands

| Scope | Used by |
| --- | --- |
| `read:space:confluence` | `Get-ConfluenceSpace`, `Get-ConfluenceSiteInfo` |
| `read:space.permission:confluence` | `Get-ConfluenceSpacePermission` |
| `read:space.property:confluence` | `Get-ConfluenceSpaceProperty` |
| `read:page:confluence` | `Get-ConfluencePage`, `Get-ConfluencePageChild`, `Get-ConfluencePageVersion`, `Update-ConfluencePage` (reads before updating) |
| `read:folder:confluence` | `Get-ConfluenceFolder` |
| `read:attachment:confluence` | `Get-ConfluenceAttachment` |
| `read:comment:confluence` | `Get-ConfluenceComment` |
| `read:label:confluence` | `Get-ConfluenceLabel` |
| `read:content.property:confluence` | `Get-ConfluenceContentProperty` |
| `read:hierarchical-content:confluence` | `Get-ConfluenceDescendant` |
| `read:content-details:confluence` | `Get-ConfluenceRestriction`, `Get-ConfluenceCurrentUser`, `Add-ConfluenceAttachment` (upload) |
| `write:page:confluence` | `New-ConfluencePage`, `Update-ConfluencePage` |
| `write:folder:confluence` | `New-ConfluenceFolder` |
| `write:attachment:confluence` | `Add-ConfluenceAttachment` |
| `write:comment:confluence` | `Add-ConfluenceComment` |
| `write:label:confluence` | `Add-ConfluenceLabel`, `Remove-ConfluenceLabel` |
| `write:content.property:confluence` | `Set-ConfluenceContentProperty`, `Remove-ConfluenceContentProperty` |
| `delete:page:confluence` | `Remove-ConfluencePage` |
| `delete:folder:confluence` | `Remove-ConfluenceFolder` |
| `delete:attachment:confluence` | `Remove-ConfluenceAttachment` |
| `delete:comment:confluence` | `Remove-ConfluenceComment` |

> Important: `Get-ConfluenceBlogPost` needs `read:blogpost:confluence`, which is
> **not** in the configured set. Add that scope (or retire the command) — the
> `/blogposts` endpoints will otherwise return 403. There is also no
> `write:blogpost` / `delete:blogpost`, so blog posts cannot be created or removed.

## Additional scopes available for new commands

These scopes are configured but not yet backed by a command. Each row lists the
candidate cmdlets it would enable (verbs in `{}` share one scope family):

| Scope(s) | Candidate commands |
| --- | --- |
| `{read,write,delete}:custom-content:confluence` | Full custom-content CRUD: `Get-`, `New-`, `Set-`, `Remove-ConfluenceCustomContent` |
| `{read,write,delete}:database:confluence` | Database CRUD: `Get-`, `New-`, `Set-`, `Remove-ConfluenceDatabase` |
| `read:group:confluence` + `write:group:confluence` | `Get-ConfluenceGroup`, `Get-ConfluenceGroupMember`, `New-ConfluenceGroup`, `Add-`/`Remove-ConfluenceGroupMember` |
| `read:user:confluence` + `read:email-address:confluence` | `Get-ConfluenceUser` (by accountId, incl. email); simplifies `Get-ConfluenceCurrentUser` |
| `{read,write}:content.restriction:confluence` | `Add-`, `Set-`, `Remove-ConfluenceRestriction` (complements the existing `Get-ConfluenceRestriction`) |
| `read:analytics.content:confluence` | `Get-ConfluenceContentAnalytics` (page/blog view + viewer counts) |
| `write:comment:confluence` | `Set-ConfluenceComment` (update an existing comment) |
| `read:permission:confluence` + `read:content.permission:confluence` | `Test-ConfluenceContentPermission` / `Get-ConfluenceOperationCheck` |
| `{read,write}:configuration:confluence` | `Get-`/`Set-ConfluenceConfiguration` (look-and-feel / system settings; needs admin) |
| `read:space.setting:confluence` + `read:space-details:confluence` | `Get-ConfluenceSpaceSetting`; richer `Get-ConfluenceSpace` details |
| `{read,write,delete}:content:confluence`, `read:content.metadata:confluence` | Generic/classic content search & operations, e.g. `Find-ConfluenceContent` (CQL) |
| `{write,delete}:embed:confluence` | `New-`/`Remove-ConfluenceEmbed` (Smart Links) — no `read:embed`, so read-back is unavailable |
| `delete:whiteboard:confluence` | `Remove-ConfluenceWhiteboard` only — no `read:`/`write:whiteboard`, so create/read is unavailable |
| `write:audit-log:confluence` | Audit-log export/write (admin) — no `read:audit-log`, so reading records is unavailable |

## Notes

- Scopes are only an **API ceiling**. Effective access is still bounded by the
  service account's Confluence **permissions** (global and per-space), so grant it
  the matching permissions on the spaces you target. Admin APIs (`configuration`,
  `audit-log`, `group`) additionally need org/site admin rights.
- **Asymmetric sets** worth noting: `whiteboard` is delete-only; `embed` has
  write/delete but no read; `audit-log` is write-only. Commands for those can only
  cover the granted verbs.
- The module provides space-administration commands (`New-ConfluenceSpace`,
  `Update-ConfluenceSpace`, `Set-ConfluenceSpace`, `Remove-ConfluenceSpace`), but
  this token set has **no
  space-administration write** scope (`write:space` / `delete:space`): the token
  can read space settings, permissions and properties but cannot create, update
  or delete spaces until `write:space:confluence` and `delete:space:confluence`
  are added (space delete also needs `read:content.metadata:confluence`). Space
  create/update/delete are v1-only operations, and delete is asynchronous (the
  API returns HTTP 202 with a long-running task).
- A few commands reach v1 endpoints that Atlassian maps to these granular scopes:
  label add/remove (`write:label:confluence`), attachment upload
  (`write:attachment:confluence` plus `read:content-details:confluence`), page
  restriction reads and the current user (`read:content-details:confluence`).
- Atlassian applies a soft cap of roughly **50 scopes** per token; at **48** this
  set is near the cap, so adding the missing read scopes (blogpost, whiteboard,
  embed) would leave little room and may require dropping unused ones.
- Reference: [Confluence OAuth 2.0 scopes](https://developer.atlassian.com/cloud/confluence/scopes-for-oauth-2-3LO-and-forge-apps/).
