[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester test cases assign variables that are used in other scopes.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'The API token is supplied as a CI environment secret and must be converted to a SecureString for Connect-Confluence.')]
[CmdletBinding()]
param()

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
                    'Get-ConfluenceSpace'
                    'Get-ConfluenceSiteInfo'
                    'New-ConfluencePage'
                    'Get-ConfluencePage'
                    'Set-ConfluencePage'
                    'Remove-ConfluencePage'
                    'Get-ConfluenceBlogPost'
                    'New-ConfluenceFolder'
                    'Add-ConfluenceComment'
                    'Add-ConfluenceLabel'
                    'Get-ConfluenceContentProperty'
                    'Get-ConfluenceAttachment'
                    'Get-ConfluenceRestriction'
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

    # Integration tests run only when live credentials are provided through the
    # repository's GitHub Environment secrets. They are skipped locally and on
    # pull requests where the secrets are not available.
    Context 'Integration' -Skip:([string]::IsNullOrEmpty($env:CONFLUENCE_API_TOKEN)) {
        BeforeAll {
            $secureToken = ConvertTo-SecureString -String $env:CONFLUENCE_API_TOKEN -AsPlainText -Force
            $connectParams = @{
                ApiBaseUri = $env:CONFLUENCE_API_BASE_URI
                Username   = $env:CONFLUENCE_USERNAME
                Token      = $secureToken
                SpaceKey   = $env:CONFLUENCE_SPACE_KEY
                Name       = 'ci'
            }
            Connect-Confluence @connectParams
        }

        AfterAll {
            Disconnect-Confluence -Name 'ci' -ErrorAction SilentlyContinue
        }

        It 'resolves the current user' {
            Get-ConfluenceCurrentUser -Context 'ci' | Should -Not -BeNullOrEmpty
        }

        It 'resolves the configured space' {
            (Get-ConfluenceSpace -Key $env:CONFLUENCE_SPACE_KEY -Context 'ci').key | Should -Be $env:CONFLUENCE_SPACE_KEY
        }
    }
}
