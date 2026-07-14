#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Context'; ModuleVersion = '8.1.6'; MaximumVersion = '8.999.999' }

#SkipTest:FunctionTest:Integration tests are added once the repository Confluence credentials are configured.
function Invoke-ConfluenceRestMethod {
    <#
        .SYNOPSIS
        Call the Confluence REST API using a stored (or supplied) context.

        .DESCRIPTION
        The single generic entry point that every other Confluence function is
        built on. It resolves the credential context, builds the HTTP Basic auth
        header, sends the request, and surfaces API errors as terminating errors.
        With -All it transparently follows v2 cursor pagination and returns the
        aggregated 'results'. Error messages include Atlassian's
        'X-Failure-Category' response header when present (for example
        FAILURE_CLIENT_SCOPE_CHECK), which distinguishes a missing-scope
        rejection from other failures. Pass -Debug to emit the full request and
        response (status, headers, and body); the Authorization header is
        redacted.

        .EXAMPLE
        ```powershell
        Invoke-ConfluenceRestMethod -ApiEndpoint '/wiki/api/v2/spaces' -Query @{ limit = 1 }
        ```

        Calls the spaces endpoint directly and returns the raw response.

        .LINK
        https://psmodule.io/Confluence/Functions/API/Invoke-ConfluenceRestMethod/

        .LINK
        https://developer.atlassian.com/cloud/confluence/rest/v2/intro/

        .LINK
        https://developer.atlassian.com/cloud/confluence/scopes-for-oauth-2-3LO-and-forge-apps/
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # The API path beginning with `/wiki/`, e.g. `/wiki/api/v2/pages`.
        # A full absolute URL is also accepted (used when following pagination links).
        # When -ApiVersion is supplied this is treated as a path relative to that
        # API family's root (e.g. -ApiVersion v2 -ApiEndpoint 'spaces').
        [Parameter(Mandatory)]
        [string]$ApiEndpoint,

        # Optional API family. Uses the internal map to prepend the version prefix
        # (v1 -> `/wiki/rest/api`, v2 -> `/wiki/api/v2`) to a relative -ApiEndpoint.
        [ValidateSet('v1', 'v2')]
        [string]$ApiVersion,

        # The HTTP method. Defaults to GET.
        [ValidateSet('GET', 'POST', 'PUT', 'DELETE')]
        [string]$Method = 'GET',

        # The request body as a hashtable/object (serialized to JSON) or a pre-serialized JSON string.
        [object]$Body,

        # A multipart/form-data payload (used for attachment uploads).
        [hashtable]$Form,

        # Query-string parameters as a hashtable.
        [hashtable]$Query,

        # Follow pagination and return every item from the 'results' collections.
        [switch]$All,

        # The context to use: an object, a context name, or $null for the default.
        [object]$Context
    )

    if ($All -and $Method -ne 'GET') {
        throw "The -All switch follows pagination and is only valid for GET requests, not $Method."
    }

    # Resolve a relative endpoint against the internal v1/v2 map when a version is given.
    # An endpoint that is already absolute - a full URL, or one that already carries the
    # /wiki/... root - is used as-is, so combining -ApiVersion with an already-versioned path
    # does not double the prefix (e.g. /wiki/api/v2/wiki/api/v2/spaces).
    if ($ApiVersion -and $ApiEndpoint -notmatch '^https?://' -and $ApiEndpoint -notlike '/wiki/*') {
        $ApiEndpoint = '{0}/{1}' -f $script:Confluence.ApiPaths[$ApiVersion], $ApiEndpoint.TrimStart('/')
    }

    $resolved = Resolve-ConfluenceContext -Context $Context
    $token = Resolve-ConfluenceToken -Token $resolved.Token
    $pair = '{0}:{1}' -f $resolved.Username, $token
    $authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pair))

    # For v2 collection endpoints, default the page size from the PerPage config so
    # -All pages in configured-sized batches instead of Confluence's small server
    # default (~25), unless the caller passed an explicit limit. Absolute _links.next
    # URLs and v1 endpoints are left untouched.
    $effectiveQuery = if ($Query) { @{} + $Query } else { @{} }
    if ($All -and $ApiEndpoint -like '/wiki/api/v2/*' -and -not ($effectiveQuery.Keys | Where-Object { $_ -ieq 'limit' })) {
        Initialize-ConfluenceConfig
        $perPage = $script:Confluence.Config['PerPage']
        if ($perPage) {
            $effectiveQuery['limit'] = $perPage
        }
    }

    $endpoint = $ApiEndpoint
    if ($effectiveQuery.Count -gt 0) {
        $pairs = foreach ($entry in $effectiveQuery.GetEnumerator()) {
            '{0}={1}' -f [uri]::EscapeDataString([string]$entry.Key), [uri]::EscapeDataString([string]$entry.Value)
        }
        $separator = if ($endpoint.Contains('?')) { '&' } else { '?' }
        $endpoint = '{0}{1}{2}' -f $endpoint, $separator, ($pairs -join '&')
    }

    $paginate = $All.IsPresent
    $debug = $DebugPreference -eq 'Continue'

    do {
        $uri = if ($endpoint -match '^https?://') { $endpoint } else { '{0}{1}' -f $resolved.ApiBaseUri, $endpoint }

        $headers = @{
            Authorization = $authorization
            Accept        = 'application/json'
        }

        $request = @{
            Uri                     = $uri
            Method                  = $Method
            Headers                 = $headers
            SkipHttpErrorCheck      = $true
            StatusCodeVariable      = 'statusCode'
            ResponseHeadersVariable = 'responseHeaders'
        }

        if ($Form) {
            $headers['X-Atlassian-Token'] = 'no-check'
            $request['Form'] = $Form
        } elseif ($null -ne $Body) {
            $request['ContentType'] = 'application/json'
            # Serialize with -InputObject rather than the pipeline: piping a
            # single-element array to ConvertTo-Json emits a bare object and loses
            # the array, whereas -InputObject serializes arrays and objects faithfully.
            $request['Body'] = if ($Body -is [string]) { $Body } else { ConvertTo-Json -InputObject $Body -Depth 20 -Compress }
        }

        if ($debug) {
            Write-Debug "Request: $Method $uri"
            foreach ($headerName in ($headers.Keys | Sort-Object)) {
                $headerValue = if ($headerName -eq 'Authorization') { 'Basic <redacted>' } else { $headers[$headerName] }
                Write-Debug ('Request header  {0}: {1}' -f $headerName, $headerValue)
            }
            if ($request.ContainsKey('Body')) {
                Write-Debug "Request body: $($request['Body'])"
            }
        }

        # -Debug:$false suppresses Invoke-RestMethod's built-in debug, which would
        # otherwise dump the raw Authorization header (the Basic credential). The
        # redacted request/response debug below is emitted under our control instead.
        $response = Invoke-RestMethod @request -Debug:$false

        if ($debug) {
            Write-Debug "Response status: $statusCode"
            foreach ($headerName in ($responseHeaders.Keys | Sort-Object)) {
                Write-Debug ('Response header {0}: {1}' -f $headerName, ($responseHeaders[$headerName] -join '; '))
            }
            $responseText = if ($null -eq $response) { '<empty>' } else { $response | ConvertTo-Json -Depth 20 }
            foreach ($line in ($responseText -split '\r?\n')) {
                Write-Debug "Response body: $line"
            }
        }

        if ($statusCode -ge 400) {
            $detail = if ($null -eq $response) {
                ''
            } elseif ($response.PSObject.Properties.Name -contains 'message' -and $response.message) {
                $response.message
            } elseif ($response.PSObject.Properties.Name -contains 'errors' -and $response.errors) {
                ($response.errors | ForEach-Object { $_.title ?? $_.detail } | Where-Object { $_ }) -join '; '
            } else {
                ($response | ConvertTo-Json -Depth 5 -Compress)
            }
            $message = "Confluence API $Method $uri failed with HTTP $statusCode. $detail".Trim()
            $category = $responseHeaders['X-Failure-Category'] | Select-Object -First 1
            if ($category) {
                $message = '{0} (failure category: {1})' -f $message, $category
            }
            throw $message
        }

        if (-not $paginate -or $null -eq $response -or $response.PSObject.Properties.Name -notcontains 'results') {
            return $response
        }

        foreach ($item in $response.results) {
            $item
        }
        $next = $response._links.next
        $endpoint = if ([string]::IsNullOrEmpty($next)) { $null } else { [string]$next }
    } while ($endpoint)
}
