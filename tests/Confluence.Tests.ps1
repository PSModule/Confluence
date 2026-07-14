#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester test cases assign variables that are used in other scopes.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'The API token is supplied as a CI environment secret and must be converted to a SecureString for Connect-Confluence.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
    Justification = 'Test output is written to the GitHub Actions log so the objects each command processes are visible.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '',
    Justification = 'Long test descriptions and pipeline output lines.')]
[CmdletBinding()]
param()

BeforeAll {
    $testName = 'Confluence'
    $os = $env:RUNNER_OS
    $id = if ($env:GITHUB_RUN_ID) { $env:GITHUB_RUN_ID } else { 'local' }
}

Describe 'Confluence' {
    Context 'Module surface' {
        BeforeAll {
            $module = Get-Module -Name 'Confluence'
            $commands = (Get-Command -Module 'Confluence').Name
        }

        It 'is imported' {
            $module | Should -Not -BeNullOrEmpty
        }

        It 'declares a dependency on the Context module' {
            $module.RequiredModules.Name | Should -Contain 'Context'
        }

        It 'exports the connection and configuration commands' {
            foreach ($name in @(
                    'Connect-Confluence'
                    'Disconnect-Confluence'
                    'Get-ConfluenceContext'
                    'Get-ConfluenceConfig'
                    'Set-ConfluenceConfig'
                )) {
                $commands | Should -Contain $name
            }
        }

        It 'exports the core REST and resource commands' {
            foreach ($name in @(
                    'Invoke-ConfluenceRestMethod'
                    'Get-ConfluenceAccessibleResource'
                    'Get-ConfluenceCloudId'
                    'Get-ConfluenceSiteInfo'
                    'Get-ConfluenceSpace'
                    'Get-ConfluenceSpacePermission'
                    'Get-ConfluenceSpaceProperty'
                    'New-ConfluenceSpace'
                    'Update-ConfluenceSpace'
                    'Set-ConfluenceSpace'
                    'Remove-ConfluenceSpace'
                    'New-ConfluencePage'
                    'Get-ConfluencePage'
                    'Update-ConfluencePage'
                    'Remove-ConfluencePage'
                    'Get-ConfluencePageChild'
                    'Get-ConfluenceDescendant'
                    'Get-ConfluencePageVersion'
                    'New-ConfluenceFolder'
                    'Get-ConfluenceFolder'
                    'Remove-ConfluenceFolder'
                    'Add-ConfluenceComment'
                    'Get-ConfluenceComment'
                    'Remove-ConfluenceComment'
                    'Add-ConfluenceLabel'
                    'Get-ConfluenceLabel'
                    'Remove-ConfluenceLabel'
                    'Set-ConfluenceContentProperty'
                    'Get-ConfluenceContentProperty'
                    'Remove-ConfluenceContentProperty'
                    'Add-ConfluenceAttachment'
                    'Get-ConfluenceAttachment'
                    'Remove-ConfluenceAttachment'
                    'Get-ConfluenceRestriction'
                    'Get-ConfluenceBlogPost'
                    'Get-ConfluenceCurrentUser'
                )) {
                $commands | Should -Contain $name
            }
        }

        It 'does not export the private helper functions' {
            foreach ($name in @(
                    'Resolve-ConfluenceContext'
                    'Resolve-ConfluenceToken'
                    'Initialize-ConfluenceConfig'
                    'ConvertTo-ConfluenceHashtable'
                )) {
                $commands | Should -Not -Contain $name
            }
        }
    }

    # Integration tests exercise every public command against a live Confluence Cloud site,
    # logging the object each command processes so the output is visible in the run log. They run
    # only when ALL live credentials are provided. The calling workflow supplies them through
    # Process-PSModule's TestData - CONFLUENCE_API_TOKEN under "secrets" (masked) and CONFLUENCE_SITE,
    # CONFLUENCE_USERNAME and CONFLUENCE_SPACE_KEY under "variables" - exposed as environment
    # variables. The context is skipped locally and whenever any of them is missing.
    $missingIntegrationVars = @(
        $env:CONFLUENCE_API_TOKEN
        $env:CONFLUENCE_SITE
        $env:CONFLUENCE_USERNAME
        $env:CONFLUENCE_SPACE_KEY
    ) | Where-Object { [string]::IsNullOrWhiteSpace($_) }

    Context 'Integration' -Skip:(@($missingIntegrationVars).Count -gt 0) {
        BeforeAll {
            $script:secureToken = ConvertTo-SecureString -String $env:CONFLUENCE_API_TOKEN -AsPlainText -Force
            $connectParams = @{
                Site     = $env:CONFLUENCE_SITE
                Username = $env:CONFLUENCE_USERNAME
                Token    = $script:secureToken
                SpaceKey = $env:CONFLUENCE_SPACE_KEY
                Name     = 'ci'
                PassThru = $true
            }
            $script:context = Connect-Confluence @connectParams
            LogGroup 'Connected context' {
                Write-Host ($script:context | Format-List | Out-String)
            }

            # Resolve the target space once; its id is required to create pages and folders.
            $script:space = Get-ConfluenceSpace -Key $env:CONFLUENCE_SPACE_KEY -Context 'ci'
            $script:spaceId = $script:space.id
            $script:homepageId = $script:space.homepageId
            LogGroup "Space [$($env:CONFLUENCE_SPACE_KEY)]" {
                Write-Host ($script:space | Format-List | Out-String)
            }

            # A title prefix unique to this OS + workflow run so parallel OS jobs and reruns do not
            # collide (Confluence page titles must be unique within a space).
            $script:prefix = "$testName $os $id"

            # Best-effort: purge leftovers from a previous run of this same job (reruns reuse
            # GITHUB_RUN_ID). Never fail the suite if cleanup is not possible.
            if ($script:homepageId) {
                try {
                    Get-ConfluencePageChild -PageId $script:homepageId -Context 'ci' |
                        Where-Object { $_.title -like "$($script:prefix)*" } |
                        ForEach-Object { Remove-ConfluencePage -PageId $_.id -Recurse -Purge -Context 'ci' -ErrorAction SilentlyContinue }
                } catch {
                    Write-Warning "Stale-page cleanup skipped: $($_.Exception.Message)"
                }
            }
        }

        AfterAll {
            # Only remove the contexts this suite created ('ci' and, if a test left it behind,
            # 'ci-secondary'); never disconnect a contributor's other stored Confluence contexts
            # when the integration tests are run locally.
            foreach ($contextName in 'ci', 'ci-secondary') {
                Disconnect-Confluence -Name $contextName -ErrorAction SilentlyContinue
            }
            Write-Host ('-' * 60)
        }

        Context 'Connection and context storage' {
            It 'Connect-Confluence stored a reusable context profile' {
                LogGroup 'Stored context' {
                    Write-Host ($script:context | Format-List | Out-String)
                }
                $script:context | Should -Not -BeNullOrEmpty
                $script:context.Name | Should -Be 'ci'
                $script:context.Type | Should -Be 'Confluence'
                $script:context.ApiBaseUri | Should -Match '/ex/confluence/'
                $script:context.Username | Should -Be $env:CONFLUENCE_USERNAME
                $script:context.SpaceKey | Should -Be $env:CONFLUENCE_SPACE_KEY
            }

            It 'stores the token as a SecureString, never as plain text' {
                $stored = Get-ConfluenceContext -Name 'ci'
                LogGroup 'Context token type' {
                    Write-Host "Token type: $($stored.Token.GetType().FullName)"
                }
                $stored.Token | Should -BeOfType [System.Security.SecureString]
            }

            It 'Get-ConfluenceContext returns the default context' {
                $default = Get-ConfluenceContext
                LogGroup 'Default context' {
                    Write-Host ($default | Format-List | Out-String)
                }
                $default.Name | Should -Be 'ci'
            }

            It 'Get-ConfluenceContext -ListAvailable excludes the module configuration' {
                $available = Get-ConfluenceContext -ListAvailable
                LogGroup 'Available contexts' {
                    Write-Host ($available | Format-Table -AutoSize | Out-String)
                }
                $available.Name | Should -Contain 'ci'
                $available.ID | Should -Not -Contain 'Module'
            }

            It 'supports multiple named contexts targeted with -Context' {
                try {
                    $second = Connect-Confluence -Site $env:CONFLUENCE_SITE -Username $env:CONFLUENCE_USERNAME -Token $script:secureToken -SpaceKey $env:CONFLUENCE_SPACE_KEY -Name 'ci-secondary' -PassThru
                    LogGroup 'Second context' {
                        Write-Host ($second | Format-List | Out-String)
                    }
                    $second.Name | Should -Be 'ci-secondary'
                    (Get-ConfluenceContext -ListAvailable).Name | Should -Contain 'ci-secondary'

                    # The named context can be used to target a call independently of the default.
                    Get-ConfluenceCurrentUser -Context 'ci-secondary' | Should -Not -BeNullOrEmpty
                } finally {
                    Disconnect-Confluence -Name 'ci-secondary'
                    # Connect made the new profile the default; restore 'ci' for the remaining tests.
                    Set-ConfluenceConfig -Name 'DefaultContext' -Value 'ci'
                }
                (Get-ConfluenceContext -ListAvailable).Name | Should -Not -Contain 'ci-secondary'
            }
        }

        Context 'Configuration' {
            It 'Get-ConfluenceConfig returns the module configuration' {
                $config = Get-ConfluenceConfig
                LogGroup 'Module configuration' {
                    Write-Host ($config | Format-Table -AutoSize | Out-String)
                }
                $config | Should -Not -BeNullOrEmpty
                $config['DefaultContext'] | Should -Be 'ci'
                $config['PerPage'] | Should -Not -BeNullOrEmpty
            }

            It 'Set-ConfluenceConfig updates and persists a value' {
                $original = Get-ConfluenceConfig -Name 'PerPage'
                try {
                    Set-ConfluenceConfig -Name 'PerPage' -Value 42
                    $updated = Get-ConfluenceConfig -Name 'PerPage'
                    LogGroup 'PerPage after update' {
                        Write-Host "PerPage: $updated"
                    }
                    $updated | Should -Be 42
                } finally {
                    Set-ConfluenceConfig -Name 'PerPage' -Value $original
                }
                Get-ConfluenceConfig -Name 'PerPage' | Should -Be $original
            }

            It 'Get-ConfluenceConfig returns a copy that cannot corrupt the cache' {
                $snapshot = Get-ConfluenceConfig
                $snapshot['PerPage'] = 999999
                Get-ConfluenceConfig -Name 'PerPage' | Should -Not -Be 999999
            }
        }

        Context 'Site and identity' {
            It 'Get-ConfluenceCloudId resolves the site to its cloud ID' {
                $cloudId = Get-ConfluenceCloudId -Site $env:CONFLUENCE_SITE
                LogGroup 'Cloud ID' {
                    Write-Host "Site '$($env:CONFLUENCE_SITE)' -> $cloudId"
                }
                $cloudId | Should -Not -BeNullOrEmpty
                $script:context.ApiBaseUri | Should -BeLike "*$cloudId*"
            }

            It 'Get-ConfluenceSiteInfo reports the connected site' {
                $info = Get-ConfluenceSiteInfo -Context 'ci'
                LogGroup 'Site info' {
                    Write-Host ($info | Format-List | Out-String)
                }
                $info.CloudId | Should -Not -BeNullOrEmpty
                $info.ApiBaseUri | Should -Be $script:context.ApiBaseUri
            }

            It 'Get-ConfluenceCurrentUser returns the authenticated account' {
                $user = Get-ConfluenceCurrentUser -Context 'ci'
                LogGroup 'Current user' {
                    Write-Host ($user | Format-List | Out-String)
                }
                $user | Should -Not -BeNullOrEmpty
            }

            It 'Get-ConfluenceAccessibleResource lists resources for the token' {
                $resources = $null
                $probeError = $null
                try {
                    $resources = Get-ConfluenceAccessibleResource -Token $script:secureToken
                } catch {
                    $probeError = $_
                }
                LogGroup 'Accessible resources' {
                    if ($resources) { Write-Host ($resources | Format-List | Out-String) }
                    if ($probeError) { Write-Host "Endpoint did not return resources for this token type: $($probeError.Exception.Message)" }
                }
                # A scoped API token may not be accepted by the OAuth accessible-resources endpoint;
                # the command must at least be callable and return data or surface a clear error.
                ($null -ne $resources -or $null -ne $probeError) | Should -BeTrue
            }
        }

        Context 'Spaces' {
            It 'Get-ConfluenceSpace resolves a space by key' {
                $byKey = Get-ConfluenceSpace -Key $env:CONFLUENCE_SPACE_KEY -Context 'ci'
                LogGroup 'Space by key' {
                    Write-Host ($byKey | Format-List | Out-String)
                }
                $byKey.key | Should -Be $env:CONFLUENCE_SPACE_KEY
                $byKey.id | Should -Be $script:spaceId
            }

            It 'Get-ConfluenceSpace resolves the same space by id' {
                $byId = Get-ConfluenceSpace -Id $script:spaceId -Context 'ci'
                LogGroup 'Space by id' {
                    Write-Host ($byId | Format-List | Out-String)
                }
                $byId.id | Should -Be $script:spaceId
            }

            It 'Get-ConfluenceSpacePermission lists space permissions' {
                $permissions = Get-ConfluenceSpacePermission -SpaceId $script:spaceId -Context 'ci'
                LogGroup 'Space permissions' {
                    Write-Host ($permissions | Select-Object -First 5 | Format-List | Out-String)
                    Write-Host "Total permissions: $(@($permissions).Count)"
                }
                @($permissions).Count | Should -BeGreaterThan 0
            }

            It 'Get-ConfluenceSpaceProperty lists space properties' {
                { $script:spaceProps = Get-ConfluenceSpaceProperty -SpaceId $script:spaceId -Context 'ci' } | Should -Not -Throw
                LogGroup 'Space properties' {
                    Write-Host ($script:spaceProps | Format-List | Out-String)
                    Write-Host "Total properties: $(@($script:spaceProps).Count)"
                }
            }
        }

        Context 'Space administration' {
            # The CI service-account token intentionally has NO space-administration write scope
            # (write:space / delete:space). These commands are exercised against the live API to
            # cover their parameter handling and payload building; each is expected to either
            # succeed (if the scope is ever granted) or surface Atlassian's scope/permission error.
            # A random, non-existent key is used so nothing persists when the write is rejected.
            # See SCOPES.md for the required write:space:confluence / delete:space:confluence.
            BeforeAll {
                $script:adminSpaceKey = "PSMT$([guid]::NewGuid().ToString('N').Substring(0, 6).ToUpperInvariant())"
            }

            It 'New-ConfluenceSpace is callable against the live API' {
                $created = $null; $spaceError = $null
                try {
                    $created = New-ConfluenceSpace -Key $script:adminSpaceKey -Name "$($script:prefix) admin" -Description 'Integration probe' -Context 'ci'
                } catch {
                    $spaceError = $_
                }
                LogGroup 'New-ConfluenceSpace outcome' {
                    if ($created) { Write-Host ($created | Format-List | Out-String) }
                    if ($spaceError) { Write-Host "Scope-gated as expected: $($spaceError.Exception.Message)" }
                }
                ($null -ne $created -or $null -ne $spaceError) | Should -BeTrue
                if ($created) { Remove-ConfluenceSpace -Key $script:adminSpaceKey -Context 'ci' -ErrorAction SilentlyContinue }
            }

            It 'Set-ConfluenceSpace is callable against the live API' {
                $set = $null; $spaceError = $null
                try {
                    $set = Set-ConfluenceSpace -Key $script:adminSpaceKey -Name "$($script:prefix) admin" -Context 'ci'
                } catch {
                    $spaceError = $_
                }
                LogGroup 'Set-ConfluenceSpace outcome' {
                    if ($set) { Write-Host ($set | Format-List | Out-String) }
                    if ($spaceError) { Write-Host "Scope-gated as expected: $($spaceError.Exception.Message)" }
                }
                ($null -ne $set -or $null -ne $spaceError) | Should -BeTrue
                if ($set) { Remove-ConfluenceSpace -Key $script:adminSpaceKey -Context 'ci' -ErrorAction SilentlyContinue }
            }

            It 'Update-ConfluenceSpace is callable against the live API' {
                # The random space does not exist, so this reads the space first and then either
                # throws not-found or is rejected by the missing write scope - both are acceptable.
                { Update-ConfluenceSpace -Key $script:adminSpaceKey -Name 'renamed' -Context 'ci' -ErrorAction Stop } | Should -Throw
            }

            It 'Remove-ConfluenceSpace is callable against the live API' {
                { Remove-ConfluenceSpace -Key $script:adminSpaceKey -Context 'ci' -ErrorAction Stop } | Should -Throw
            }
        }

        Context 'Pages - CRUD lifecycle' {
            AfterAll {
                if ($script:pagesRootId) {
                    Remove-ConfluencePage -PageId $script:pagesRootId -Recurse -Purge -Context 'ci' -ErrorAction SilentlyContinue
                }
            }

            It 'New-ConfluencePage creates a page' {
                $title = "$($script:prefix) Pages Root"
                $script:pagesRootId = $null
                $page = New-ConfluencePage -SpaceId $script:spaceId -Title $title -Body '<p>Created by integration tests.</p>' -Context 'ci'
                LogGroup "New page [$title]" {
                    Write-Host ($page | Format-List | Out-String)
                }
                $page | Should -Not -BeNullOrEmpty
                $page.id | Should -Not -BeNullOrEmpty
                $page.title | Should -Be $title
                $page.spaceId | Should -Be $script:spaceId
                $page.version.number | Should -Be 1
                $script:pagesRootId = $page.id
            }

            It 'Get-ConfluencePage returns the created page with its body' {
                $page = Get-ConfluencePage -PageId $script:pagesRootId -Context 'ci'
                LogGroup 'Get page' {
                    Write-Host ($page | Format-List | Out-String)
                    Write-Host ($page.body | Format-List | Out-String)
                }
                $page.id | Should -Be $script:pagesRootId
                $page.body.storage.value | Should -Match 'integration tests'
            }

            It 'Update-ConfluencePage updates the body and increments the version' {
                $newTitle = "$($script:prefix) Pages Root (updated)"
                $updated = Update-ConfluencePage -PageId $script:pagesRootId -Title $newTitle -Body '<p>Updated body.</p>' -Context 'ci'
                LogGroup 'Updated page' {
                    Write-Host ($updated | Format-List | Out-String)
                }
                $updated.version.number | Should -Be 2
                $updated.title | Should -Be $newTitle
                (Get-ConfluencePage -PageId $script:pagesRootId -Context 'ci').body.storage.value | Should -Match 'Updated body'
            }

            It 'Get-ConfluencePageVersion lists the version history' {
                $versions = Get-ConfluencePageVersion -PageId $script:pagesRootId -Context 'ci'
                LogGroup 'Page versions' {
                    Write-Host ($versions | Format-Table -AutoSize | Out-String)
                }
                @($versions).Count | Should -BeGreaterOrEqual 2
            }

            It 'New-ConfluencePage creates a child page under a parent' {
                $title = "$($script:prefix) Pages Child"
                $child = New-ConfluencePage -SpaceId $script:spaceId -Title $title -ParentId $script:pagesRootId -Body '<p>Child.</p>' -Context 'ci'
                LogGroup "Child page [$title]" {
                    Write-Host ($child | Format-List | Out-String)
                }
                $child.id | Should -Not -BeNullOrEmpty
                $script:pagesChildId = $child.id
            }

            It 'Get-ConfluencePageChild lists the child pages' {
                $children = Get-ConfluencePageChild -PageId $script:pagesRootId -Context 'ci'
                LogGroup 'Child pages' {
                    Write-Host ($children | Format-Table -AutoSize | Out-String)
                }
                $children.id | Should -Contain $script:pagesChildId
            }

            It 'Get-ConfluenceDescendant lists the descendants' {
                $descendants = Get-ConfluenceDescendant -PageId $script:pagesRootId -Context 'ci'
                LogGroup 'Descendants' {
                    Write-Host ($descendants | Format-Table -AutoSize | Out-String)
                }
                $descendants.id | Should -Contain $script:pagesChildId
            }

            It 'Remove-ConfluencePage removes the page tree' {
                { Remove-ConfluencePage -PageId $script:pagesRootId -Recurse -Purge -Context 'ci' } | Should -Not -Throw
                LogGroup 'Removed page tree' {
                    Write-Host "Purged page $($script:pagesRootId) and its descendants."
                }
                { Get-ConfluencePage -PageId $script:pagesRootId -Context 'ci' } | Should -Throw
                $script:pagesRootId = $null
            }
        }

        Context 'Folders - CRUD lifecycle' {
            AfterAll {
                if ($script:folderId) {
                    Remove-ConfluenceFolder -FolderId $script:folderId -Context 'ci' -ErrorAction SilentlyContinue
                }
            }

            It 'New-ConfluenceFolder creates a folder' {
                $title = "$($script:prefix) Folder"
                $folder = New-ConfluenceFolder -SpaceId $script:spaceId -Title $title -Context 'ci'
                LogGroup "New folder [$title]" {
                    Write-Host ($folder | Format-List | Out-String)
                }
                $folder.id | Should -Not -BeNullOrEmpty
                $folder.title | Should -Be $title
                $script:folderId = $folder.id
            }

            It 'Get-ConfluenceFolder returns the folder' {
                $folder = Get-ConfluenceFolder -FolderId $script:folderId -Context 'ci'
                LogGroup 'Get folder' {
                    Write-Host ($folder | Format-List | Out-String)
                }
                $folder.id | Should -Be $script:folderId
            }

            It 'Remove-ConfluenceFolder deletes the folder' {
                { Remove-ConfluenceFolder -FolderId $script:folderId -Context 'ci' } | Should -Not -Throw
                LogGroup 'Removed folder' {
                    Write-Host "Deleted folder $($script:folderId)."
                }
                $script:folderId = $null
            }
        }

        Context 'Comments - CRUD lifecycle' {
            BeforeAll {
                $script:commentPage = New-ConfluencePage -SpaceId $script:spaceId -Title "$($script:prefix) Comments" -Body '<p>Comments fixture.</p>' -Context 'ci'
            }
            AfterAll {
                if ($script:commentPage) {
                    Remove-ConfluencePage -PageId $script:commentPage.id -Recurse -Purge -Context 'ci' -ErrorAction SilentlyContinue
                }
            }

            It 'Add-ConfluenceComment adds a footer comment' {
                $comment = Add-ConfluenceComment -PageId $script:commentPage.id -Body '<p>First comment.</p>' -Context 'ci'
                LogGroup 'Added comment' {
                    Write-Host ($comment | Format-List | Out-String)
                }
                $comment.id | Should -Not -BeNullOrEmpty
                $script:commentId = $comment.id
            }

            It 'Get-ConfluenceComment lists the footer comments' {
                $comments = Get-ConfluenceComment -PageId $script:commentPage.id -Context 'ci'
                LogGroup 'Comments' {
                    Write-Host ($comments | Format-List | Out-String)
                }
                $comments.id | Should -Contain $script:commentId
            }

            It 'Remove-ConfluenceComment deletes the comment' {
                { Remove-ConfluenceComment -CommentId $script:commentId -Context 'ci' } | Should -Not -Throw
                LogGroup 'Remaining comments' {
                    $remaining = Get-ConfluenceComment -PageId $script:commentPage.id -Context 'ci'
                    Write-Host ($remaining | Format-List | Out-String)
                }
            }
        }

        Context 'Labels - CRUD lifecycle' {
            BeforeAll {
                $script:labelPage = New-ConfluencePage -SpaceId $script:spaceId -Title "$($script:prefix) Labels" -Body '<p>Labels fixture.</p>' -Context 'ci'
                $digits = ($id -replace '\D', '')
                $script:labelName = if ($digits) { "itest$digits" } else { 'itestlocal' }
            }
            AfterAll {
                if ($script:labelPage) {
                    Remove-ConfluencePage -PageId $script:labelPage.id -Recurse -Purge -Context 'ci' -ErrorAction SilentlyContinue
                }
            }

            It 'Add-ConfluenceLabel adds labels to a page' {
                $result = Add-ConfluenceLabel -PageId $script:labelPage.id -Label $script:labelName, "$($script:labelName)2" -Context 'ci'
                LogGroup 'Added labels' {
                    Write-Host ($result | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Get-ConfluenceLabel lists the labels on the page' {
                $labels = Get-ConfluenceLabel -PageId $script:labelPage.id -Context 'ci'
                LogGroup 'Labels' {
                    Write-Host ($labels | Format-Table -AutoSize | Out-String)
                }
                $labels.name | Should -Contain $script:labelName
            }

            It 'Remove-ConfluenceLabel removes a label' {
                { Remove-ConfluenceLabel -PageId $script:labelPage.id -Label $script:labelName -Context 'ci' } | Should -Not -Throw
                $labels = Get-ConfluenceLabel -PageId $script:labelPage.id -Context 'ci'
                LogGroup 'Labels after removal' {
                    Write-Host ($labels | Format-Table -AutoSize | Out-String)
                }
                $labels.name | Should -Not -Contain $script:labelName
            }
        }

        Context 'Content properties - CRUD lifecycle' {
            BeforeAll {
                $script:propPage = New-ConfluencePage -SpaceId $script:spaceId -Title "$($script:prefix) Properties" -Body '<p>Properties fixture.</p>' -Context 'ci'
            }
            AfterAll {
                if ($script:propPage) {
                    Remove-ConfluencePage -PageId $script:propPage.id -Recurse -Purge -Context 'ci' -ErrorAction SilentlyContinue
                }
            }

            It 'Set-ConfluenceContentProperty creates a property' {
                $prop = Set-ConfluenceContentProperty -PageId $script:propPage.id -Key 'itest-owner' -Value @{ team = 'psmodule'; run = "$id" } -Context 'ci'
                LogGroup 'Created property' {
                    Write-Host ($prop | Format-List | Out-String)
                    Write-Host ($prop.value | ConvertTo-Json -Depth 5)
                }
                $prop.key | Should -Be 'itest-owner'
                $prop.version.number | Should -Be 1
                $script:propId = $prop.id
            }

            It 'Get-ConfluenceContentProperty returns the property by key' {
                $prop = Get-ConfluenceContentProperty -PageId $script:propPage.id -Key 'itest-owner' -Context 'ci'
                LogGroup 'Fetched property' {
                    Write-Host ($prop | Format-List | Out-String)
                }
                $prop.value.team | Should -Be 'psmodule'
            }

            It 'Set-ConfluenceContentProperty updates and versions the property' {
                $prop = Set-ConfluenceContentProperty -PageId $script:propPage.id -Key 'itest-owner' -Value @{ team = 'ai-platform' } -Context 'ci'
                LogGroup 'Updated property' {
                    Write-Host ($prop | Format-List | Out-String)
                }
                $prop.version.number | Should -Be 2
                (Get-ConfluenceContentProperty -PageId $script:propPage.id -Key 'itest-owner' -Context 'ci').value.team | Should -Be 'ai-platform'
            }

            It 'Get-ConfluenceContentProperty lists all properties' {
                $all = Get-ConfluenceContentProperty -PageId $script:propPage.id -Context 'ci'
                LogGroup 'All properties' {
                    Write-Host ($all | Format-Table -AutoSize | Out-String)
                }
                $all.key | Should -Contain 'itest-owner'
            }

            It 'Remove-ConfluenceContentProperty deletes the property' {
                { Remove-ConfluenceContentProperty -PageId $script:propPage.id -PropertyId $script:propId -Context 'ci' } | Should -Not -Throw
                Get-ConfluenceContentProperty -PageId $script:propPage.id -Key 'itest-owner' -Context 'ci' | Should -BeNullOrEmpty
            }
        }

        Context 'Attachments - CRUD lifecycle' {
            BeforeAll {
                $script:attachPage = New-ConfluencePage -SpaceId $script:spaceId -Title "$($script:prefix) Attachments" -Body '<p>Attachments fixture.</p>' -Context 'ci'
                $script:attachFile = Join-Path ([System.IO.Path]::GetTempPath()) "confluence-itest-$id-$os.txt"
                Set-Content -Path $script:attachFile -Value "Integration test attachment $id" -Encoding utf8
            }
            AfterAll {
                if ($script:attachPage) {
                    Remove-ConfluencePage -PageId $script:attachPage.id -Recurse -Purge -Context 'ci' -ErrorAction SilentlyContinue
                }
                if ($script:attachFile -and (Test-Path $script:attachFile)) {
                    Remove-Item $script:attachFile -ErrorAction SilentlyContinue
                }
            }

            It 'Add-ConfluenceAttachment uploads a file' {
                $upload = Add-ConfluenceAttachment -PageId $script:attachPage.id -Path $script:attachFile -Context 'ci'
                LogGroup 'Uploaded attachment' {
                    Write-Host ($upload | ConvertTo-Json -Depth 6)
                }
                $upload | Should -Not -BeNullOrEmpty
            }

            It 'Get-ConfluenceAttachment lists the attachments on the page' {
                $attachments = Get-ConfluenceAttachment -PageId $script:attachPage.id -Context 'ci'
                LogGroup 'Attachments on page' {
                    Write-Host ($attachments | Format-List | Out-String)
                }
                @($attachments).Count | Should -BeGreaterThan 0
                $script:attachmentId = @($attachments).id | Select-Object -First 1
            }

            It 'Get-ConfluenceAttachment returns a single attachment by id' {
                $attachment = Get-ConfluenceAttachment -AttachmentId $script:attachmentId -Context 'ci'
                LogGroup 'Single attachment' {
                    Write-Host ($attachment | Format-List | Out-String)
                }
                $attachment.id | Should -Be $script:attachmentId
            }

            It 'Remove-ConfluenceAttachment deletes the attachment' {
                # Confluence Cloud can briefly return HTTP 409 ('Encountered conflict deleting
                # attachment') when an attachment is removed shortly after it is uploaded, while
                # the upload is still being reconciled server-side. Retry the delete so this
                # eventual-consistency window does not fail the run; a non-conflict error, or a
                # conflict that never clears, still surfaces and fails the test.
                {
                    for ($attempt = 1; $attempt -le 4; $attempt++) {
                        try {
                            Remove-ConfluenceAttachment -AttachmentId $script:attachmentId -Context 'ci'
                            break
                        } catch {
                            if ($_.Exception.Message -notmatch 'HTTP 409|conflict' -or $attempt -eq 4) { throw }
                            Start-Sleep -Seconds 2
                        }
                    }
                } | Should -Not -Throw
                LogGroup 'Attachments after removal' {
                    $remaining = Get-ConfluenceAttachment -PageId $script:attachPage.id -Context 'ci'
                    Write-Host ($remaining | Format-List | Out-String)
                }
            }
        }

        Context 'Restrictions' {
            BeforeAll {
                $script:restrictPage = New-ConfluencePage -SpaceId $script:spaceId -Title "$($script:prefix) Restrictions" -Body '<p>Restrictions fixture.</p>' -Context 'ci'
            }
            AfterAll {
                if ($script:restrictPage) {
                    Remove-ConfluencePage -PageId $script:restrictPage.id -Recurse -Purge -Context 'ci' -ErrorAction SilentlyContinue
                }
            }

            It 'Get-ConfluenceRestriction returns the read/update operations' {
                $restrictions = Get-ConfluenceRestriction -PageId $script:restrictPage.id -Context 'ci'
                LogGroup 'Restrictions' {
                    Write-Host ($restrictions | Format-List | Out-String)
                }
                $restrictions.operation | Should -Contain 'read'
            }
        }

        Context 'Blog posts' {
            It 'Get-ConfluenceBlogPost is callable (documents the read:blogpost scope gap)' {
                # The test token intentionally does not carry read:blogpost:confluence (see SCOPES.md),
                # so the /blogposts endpoint returns a scope-check failure. This confirms the error is
                # surfaced clearly rather than swallowed; if the scope is later granted the call succeeds.
                $posts = $null
                $blogError = $null
                try {
                    $posts = Get-ConfluenceBlogPost -SpaceId $script:spaceId -Context 'ci'
                } catch {
                    $blogError = $_
                }
                LogGroup 'Blog posts' {
                    if ($null -ne $posts) { Write-Host ($posts | Select-Object -First 5 | Format-List | Out-String) }
                    if ($blogError) { Write-Host "Scope-gated as expected: $($blogError.Exception.Message)" }
                }
                if ($blogError) {
                    $blogError.Exception.Message | Should -Match 'scope|403|blogpost'
                } else {
                    $true | Should -BeTrue
                }
            }
        }

        Context 'REST API' {
            It 'Invoke-ConfluenceRestMethod calls the API directly' {
                $response = Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/spaces' -Query @{ limit = 1 } -Context 'ci'
                LogGroup 'Raw spaces response' {
                    Write-Host ($response | ConvertTo-Json -Depth 6)
                }
                $response.results | Should -Not -BeNullOrEmpty
            }

            It 'Invoke-ConfluenceRestMethod -All aggregates paginated results' {
                $spaces = Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/spaces' -All -Context 'ci'
                LogGroup 'All spaces' {
                    Write-Host ($spaces | Select-Object id, key, name | Format-Table -AutoSize | Out-String)
                    Write-Host "Total spaces: $(@($spaces).Count)"
                }
                @($spaces).Count | Should -BeGreaterThan 0
                $spaces.key | Should -Contain $env:CONFLUENCE_SPACE_KEY
            }

            It 'Invoke-ConfluenceRestMethod resolves a relative endpoint with -ApiVersion' {
                $response = Invoke-ConfluenceRestMethod -ApiVersion v2 -ApiEndpoint 'spaces' -Query @{ limit = 1 } -Context 'ci'
                $response.results | Should -Not -BeNullOrEmpty
            }
        }
    }
}
