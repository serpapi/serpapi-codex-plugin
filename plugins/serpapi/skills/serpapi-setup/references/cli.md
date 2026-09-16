# CLI setup

Reuse `serpapi` if it is already on PATH. Otherwise select an installation method from the [official CLI instructions](https://github.com/serpapi/serpapi-cli) that fits the host. Do not install a package manager merely to install the CLI without discussing the cURL option.

With Homebrew already installed:

```bash
brew tap serpapi/homebrew-tap
brew install serpapi-cli
```

With Go already installed:

```bash
go install github.com/serpapi/serpapi-cli/cmd/serpapi@latest
```

The Go binary directory must be on the agent's PATH. For other environments, check the official repository's current installation options.

Reuse an injected `SERPAPI_KEY`, a key loaded from the user's secret store, or an existing CLI login. Otherwise have the user run `serpapi login` in a terminal they can interact with. It hides input, checks the Account API, and saves the key. If the agent's terminal cannot receive user input, use a client secret field or the [Windows password-dialog helper](credentials.md#windows-encrypted-storage), then load the stored key into the CLI's process. Read [credentials.md](credentials.md) for storage locations and protection limits.

The CLI resolves `--api-key` first, then `SERPAPI_KEY`, then saved config. Avoid the flag because its value is visible in process arguments. If a new login appears ineffective, check for a stale environment override by presence only.

Verify with filtered output:

```bash
serpapi --version
serpapi account --jq '{account_status, total_searches_left}'
serpapi search engine=google_light q=coffee --jq 'if (.error == null and .search_metadata.status == "Success" and (.organic_results[0].title | type == "string" and length > 0) and (.organic_results[0].link | type == "string" and length > 0)) then {status: .search_metadata.status, result: (.organic_results[0] | {title, link})} else error("SerpApi probe failed; consult serpapi-setup") end'
```

The CLI embeds its jq implementation, so these commands do not require a jq installation. Account status alone does not verify search access. Apply the setup skill's success criteria to the search, including the exit status. Keep diagnostics free of raw account JSON, request URLs, and key values.
