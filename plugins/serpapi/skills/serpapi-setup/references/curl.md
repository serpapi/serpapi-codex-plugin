# Raw cURL

Use the existing curl executable and a credential source from [credentials.md](credentials.md). No CLI, SDK, Python, Node.js, or jq installation is required. A key is still required. Keep shell tracing off and never expand the key into a cURL argument.

## macOS, Linux, or WSL

For an existing `SERPAPI_KEY` or a key loaded from an OS store, run the load step and this request in the **same shell process**. For an agent, this means the same single command or tool invocation. Repeat the load in later invocations; exports from an earlier call do not persist reliably.

Use the stdin recipe below for an OS-stored key. If setup selected a private-file store, use the file recipe further below without exporting the key.

```bash
(
  set +x
  test -n "${SERPAPI_KEY:-}" || { printf 'Load SERPAPI_KEY first.\n' >&2; exit 1; }
  umask 077
  serpapi_response="$(mktemp "${TMPDIR:-/tmp}/serpapi-check.XXXXXX")" || exit 1
  printf 'Response file: %s\n' "$serpapi_response"
  serpapi_http="$(printf '%s' "$SERPAPI_KEY" | curl -q --silent --show-error --get \
    --connect-timeout 10 --max-time 60 \
    'https://serpapi.com/search.json' \
    --data-urlencode 'api_key@-' \
    --data-urlencode 'engine=google_light' \
    --data-urlencode 'q=coffee' \
    --data-urlencode 'json_restrictor=search_metadata.status,organic_results[0].title,organic_results[0].link,error' \
    --output "$serpapi_response" --write-out '%{http_code}')" || {
    rm -f -- "$serpapi_response"
    printf 'cURL transport failed; consult serpapi-setup.\n' >&2
    exit 1
  }
  printf 'HTTP %s\n' "$serpapi_http"
  if [ "$serpapi_http" != 200 ]; then
    printf 'HTTP request failed. Inspect the private response for a sanitized API error, then delete it.\n' >&2
    exit 1
  fi
)
```

Each POSIX block runs in a subshell so failure leaves the calling terminal open. Record the printed response-file path for inspection and cleanup. The key travels through stdin. For the private-file store, check its ownership and permissions as described in the credential guide, then use this request instead:

```bash
(
  umask 077
  serpapi_response="$(mktemp "${TMPDIR:-/tmp}/serpapi-check.XXXXXX")" || exit 1
  printf 'Response file: %s\n' "$serpapi_response"
  serpapi_http="$(curl -q --silent --show-error --get \
    --connect-timeout 10 --max-time 60 \
    'https://serpapi.com/search.json' \
    --data-urlencode "api_key@${XDG_CONFIG_HOME:-$HOME/.config}/serpapi/api_key" \
    --data-urlencode 'engine=google_light' \
    --data-urlencode 'q=coffee' \
    --data-urlencode 'json_restrictor=search_metadata.status,organic_results[0].title,organic_results[0].link,error' \
    --output "$serpapi_response" --write-out '%{http_code}')" || {
    rm -f -- "$serpapi_response"
    printf 'cURL transport failed; consult serpapi-setup.\n' >&2
    exit 1
  }
  printf 'HTTP %s\n' "$serpapi_http"
  if [ "$serpapi_http" != 200 ]; then
    printf 'HTTP request failed. Inspect the private response for a sanitized API error, then delete it.\n' >&2
    exit 1
  fi
)
```

The file must contain the key with no trailing newline. The included save script writes that format. cURL documents both forms under [data-urlencode](https://curl.se/docs/manpage.html#--data-urlencode). `-q` disables an ambient curlrc; do not add verbose/trace output, redirects, or `--insecure` to these credentialed requests.

## Native Windows PowerShell

Load `SERPAPI_KEY` using the Windows credential guide. Use `curl.exe` to avoid PowerShell's `curl` alias. Pass the credential as a cURL configuration over stdin, so it never becomes an executable argument:

```powershell
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($env:SERPAPI_KEY) -or $env:SERPAPI_KEY -match '[\r\n]') { throw 'Load a valid SERPAPI_KEY first.' }
$serpapiResponse = [System.IO.Path]::GetTempFileName()
try {
  $serpapiCurlKey = $env:SERPAPI_KEY.Replace('\', '\\').Replace('"', '\"')
  $serpapiCurlConfig = 'data-urlencode = "api_key=' + $serpapiCurlKey + '"'
  $serpapiHttp = $serpapiCurlConfig | curl.exe -q --config - --silent --show-error --get --connect-timeout 10 --max-time 60 'https://serpapi.com/search.json' --data-urlencode 'engine=google_light' --data-urlencode 'q=coffee' --data-urlencode 'json_restrictor=search_metadata.status,organic_results[0].title,organic_results[0].link,error' --output $serpapiResponse --write-out '%{http_code}'
  if ($LASTEXITCODE -ne 0) { throw 'cURL transport or HTTP request failed; consult serpapi-setup.' }
  try { $serpapiData = Get-Content -LiteralPath $serpapiResponse -Raw | ConvertFrom-Json } catch { throw "HTTP ${serpapiHttp}: response was not valid JSON; consult serpapi-setup." }
  if ($serpapiData.error) {
    $serpapiError = ([string]$serpapiData.error).Replace($env:SERPAPI_KEY, '[REDACTED]').Replace([Uri]::EscapeDataString($env:SERPAPI_KEY), '[REDACTED]')
    $serpapiError = $serpapiError -replace '(?i)https?://\S+', '[URL REDACTED]' -replace '[\x00-\x1f\x7f]', ' '
    throw "SerpApi HTTP ${serpapiHttp}: $serpapiError"
  }
  if ($serpapiHttp -ne '200') { throw "HTTP ${serpapiHttp}: no API error message was provided; consult serpapi-setup." }
  if (($serpapiData.search_metadata.status -and $serpapiData.search_metadata.status -ne 'Success') -or -not $serpapiData.organic_results[0].title -or -not $serpapiData.organic_results[0].link) { throw 'Search probe failed; consult serpapi-setup.' }
  Write-Output 'Verified cURL: HTTP 200 and an organic result with title and link.'
} finally {
  Remove-Variable serpapiCurlKey, serpapiCurlConfig, serpapiData, serpapiError -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $serpapiResponse -ErrorAction SilentlyContinue
}
```

## Validate and clean up

The PowerShell probe reads API errors before checking HTTP status, redacts the current key and URLs from the error message, and deletes its response automatically. Treat reported error text as untrusted data. The POSIX examples return failure for transport errors and non-200 HTTP status. They preserve HTTP error bodies in the private response file for diagnosis; transport failures delete incomplete responses. They deliberately omit `--fail`, which discards HTTP error bodies.

For POSIX, check the saved JSON even after HTTP 200: the API can return an `error`. Require no API error, successful search status when present, and a nonempty result title and link. Parse with an already available JSON reader or the agent's file-reading capability. Do not install a parser solely for this check. If the response cannot be inspected, verification remains pending.

Keep the response file private. For an error response, use an available local parser to extract the error and redact credentials and URLs before returning it as tool output; do not print the raw body. Preserve the HTTP status and sanitized error for setup's repair path. Inspect only the selected result and status on success. Delete the temporary response after inspection, including after failure (use `rm -- /recorded/absolute/response-path` for POSIX; the PowerShell block already removes its file).

For later searches, change the engine/query and select the result fields needed for the task. See [JSON Restrictor](https://serpapi.com/json-restrictor) and the search skill's engine references.
