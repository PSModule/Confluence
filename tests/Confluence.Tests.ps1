#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

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
                    'Get-ConfluenceCloudId'
                    'Get-ConfluenceAccessibleResource'
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

    # Integration tests run only when ALL live credentials are provided. The calling workflow supplies
    # them through Process-PSModule's TestData - CONFLUENCE_API_TOKEN under "secrets" (masked) and
    # CONFLUENCE_SITE, CONFLUENCE_USERNAME and CONFLUENCE_SPACE_KEY under "variables" - exposed as
    # environment variables. The context is skipped locally and whenever any of them is missing.
    $missingIntegrationVars = @(
        $env:CONFLUENCE_API_TOKEN
        $env:CONFLUENCE_SITE
        $env:CONFLUENCE_USERNAME
        $env:CONFLUENCE_SPACE_KEY
    ) | Where-Object { [string]::IsNullOrEmpty($_) }
    Context 'Integration' -Skip:(@($missingIntegrationVars).Count -gt 0) {
        BeforeAll {
            $secureToken = ConvertTo-SecureString -String $env:CONFLUENCE_API_TOKEN -AsPlainText -Force
            $connectParams = @{
                Site     = $env:CONFLUENCE_SITE
                Username = $env:CONFLUENCE_USERNAME
                Token    = $secureToken
                SpaceKey = $env:CONFLUENCE_SPACE_KEY
                Name     = 'ci'
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
