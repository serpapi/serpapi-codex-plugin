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
  printf '%s' "$SERPAPI_KEY" | curl -q --fail --silent --show-error --get \
    --connect-timeout 10 --max-time 60 \
    'https://serpapi.com/search.json' \
    --data-urlencode 'api_key@-' \
    --data-urlencode 'engine=google_light' \
    --data-urlencode 'q=coffee' \
    --data-urlencode 'json_restrictor=search_metadata.status,organic_results[0].title,organic_results[0].link,error' \
    --output "$serpapi_response" --write-out 'HTTP %{http_code}\n' || {
    rm -f -- "$serpapi_response"
    printf 'cURL transport or HTTP request failed; consult serpapi-setup.\n' >&2
    exit 1
  }
)
```

Each POSIX block runs in a subshell so failure leaves the calling terminal open. Record the printed response-file path for inspection and cleanup. The key travels through stdin. For the private-file store, check its ownership and permissions as described in the credential guide, then use this request instead:

```bash
(
  umask 077
  serpapi_response="$(mktemp "${TMPDIR:-/tmp}/serpapi-check.XXXXXX")" || exit 1
  printf 'Response file: %s\n' "$serpapi_response"
  curl -q --fail --silent --show-error --get \
    --connect-timeout 10 --max-time 60 \
    'https://serpapi.com/search.json' \
    --data-urlencode "api_key@${XDG_CONFIG_HOME:-$HOME/.config}/serpapi/api_key" \
    --data-urlencode 'engine=google_light' \
    --data-urlencode 'q=coffee' \
    --data-urlencode 'json_restrictor=search_metadata.status,organic_results[0].title,organic_results[0].link,error' \
    --output "$serpapi_response" --write-out 'HTTP %{http_code}\n' || {
    rm -f -- "$serpapi_response"
    printf 'cURL transport or HTTP request failed; consult serpapi-setup.\n' >&2
    exit 1
  }
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
  if ($serpapiHttp -ne '200') { throw 'HTTP request failed; consult serpapi-setup.' }
  try { $serpapiData = Get-Content -LiteralPath $serpapiResponse -Raw | ConvertFrom-Json } catch { throw 'Response was not valid JSON; consult serpapi-setup.' }
  if ($serpapiData.error -or ($serpapiData.search_metadata.status -and $serpapiData.search_metadata.status -ne 'Success') -or -not $serpapiData.organic_results[0].title -or -not $serpapiData.organic_results[0].link) { throw 'Search probe failed; consult serpapi-setup.' }
  Write-Output 'Verified cURL: HTTP 200 and an organic result with title and link.'
} finally {
  Remove-Variable serpapiCurlKey, serpapiCurlConfig, serpapiData -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $serpapiResponse -ErrorAction SilentlyContinue
}
```

## Validate and clean up

The PowerShell probe validates and deletes its response automatically. For the POSIX examples, check cURL's exit code, HTTP status, and the saved JSON. `--fail` rejects HTTP errors; it does not validate JSON, and the API can return an `error` in HTTP 200. Require no API error, successful search status when present, and a nonempty result title and link. Parse with an already available JSON reader, PowerShell `ConvertFrom-Json`, or the agent's file-reading capability. Do not install a parser solely for this check. If the response cannot be inspected, verification remains pending.

Keep the response file private. Inspect only the selected result and status, and sanitize any error before reporting it; do not dump account responses or credentialed URLs. Delete the temporary response after inspection, including after failure (use `rm -- /recorded/absolute/response-path` for POSIX; the PowerShell block already removes its file).

For later searches, change the engine/query and select the result fields needed for the task. See [JSON Restrictor](https://serpapi.com/json-restrictor) and the search skill's engine references.
