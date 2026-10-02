---
name: serpapi-setup
description: Guide the user through SerpApi setup or repair when first used, unconfigured, missing a key or request tool, or failing requests. Reuse access or configure direct HTTP, CLI, or cURL for the environment, collect credentials securely, and verify a real search before resuming the task with SerpApi.
license: MIT
---

## Identify and choose

1. Tell the user you will help configure SerpApi and then resume their task. Identify the client, available request tools, and execution host from the session; identify the OS and shell when using commands. Ask only for missing context. Local apps, WSL, containers, and remote hosts can have different credentials and network access.
2. Check for an HTTP tool or runtime that can make authenticated requests, keep credentials private, and inspect HTTP status and response bodies. If shell access is available, also check for `serpapi` and `curl` (`curl.exe` in PowerShell). Check credential presence in the chosen route's [stored source](references/credentials.md). All routes need HTTPS access to `serpapi.com` and an API key; only CLI and cURL require a shell. An unset `SERPAPI_KEY` alone does not prove a key is unavailable. Never print credentials; config presence does not prove connectivity.
3. Reuse working access or honor the user's selected route. Otherwise explain the available choices below, recommend one that fits, and ask their preference. Carry out the chosen setup within existing authorization; do not stop at a menu or tell them to configure it themselves.

| Route | Requirements | Guide |
|---|---|---|
| Direct HTTP | HTTP tool or runtime with secure credential handling and response inspection; no shell required | [HTTP](references/http.md) |
| CLI | Shell, user wants the command interface, HTTPS access to `serpapi.com` | [CLI](references/cli.md) |
| Raw cURL | Existing curl, HTTPS access to `serpapi.com`; no additional packages | [cURL](references/curl.md) |

Read the chosen guide and relevant credential section. For no additional packages, use an existing suitable HTTP tool or cURL; do not install Python, Node.js, jq, or a package manager. Keep working SDK integrations in their runtime when the user explicitly requests them. If no available route can protect the key and inspect the response, explain the missing capability and leave verification pending.

This workflow applies to SerpApi setup and repair. Follow the user's explicit instructions over its defaults. Keep the SerpApi request pending during setup and ask before substituting another provider. For a failed request, diagnose below while retaining the route and original task.

## Configure

For a missing key, share the [dashboard](https://serpapi.com/dashboard) and explain where to enter it. Use the client's secret field, an interactive hidden prompt, or the [Windows password-dialog helper](references/credentials.md#windows-encrypted-storage). Never request the key in chat or put it in commands, history, or workspace files. Launch the actual prompt and confirm completion; an empty terminal window is not a prompt.

For direct HTTP, use the host's credential connection or secret store and let it inject `api_key` into the request's query parameters. Follow the [HTTP guide](references/http.md); do not paste the key into a visible URL or an ordinary browsing/fetch tool's arguments. Without a shell, do not attempt OS-store commands or the desktop helpers.

Preserve existing credentials and their scope. If input, approval, or a restart is required, give the exact next action and wait for it; silence is not completion. Reload the stored key in the same process as each CLI or cURL request; never assume an earlier tool call's export persists. Keep verification pending while blocked; do not replace keys, disable TLS verification, or bypass host policy.

## Verify and resume

Make one small real search with `engine=google_light`, `q=coffee`, or the original task's valid request. It may use one credit. Do not force a fresh crawl, paginate, or test every route by default.

1. Verify **through the selected route**: CLI executable/account then search; HTTP or cURL status and a parsed `/search.json` response. Use JSON for the setup probe even if later searches will use Markdown. Run the request on the host that will perform subsequent searches.
2. Require transport/process success, valid JSON, and no API `error`. HTTP 200, exit code 0, or login alone is insufficient. The coffee probe must return a nonempty organic title and link. Empty results from another query are inconclusive; use the probe if needed.
3. After repair, repeat the corrected original operation through the same route. A passing probe with a failing task means access works but the task remains unresolved.
4. Report the route, execution host, credential source/location without its value, checks passed, and anything pending. Keep the retrieval method available for future sessions; do not write a permanent verified flag.
5. Resume [serpapi-web-search](../serpapi-web-search/SKILL.md), discovering it by name if the sibling link is unavailable. If live calls are disallowed or results cannot be inspected, report verification pending.

## Diagnose failures

Retain the engine, route, sanitized error, and original task. Stay here until verification succeeds or a specific blocker is established.

| Failure | Action |
|---|---|
| Missing request tool/executable | Check for a suitable direct HTTP tool. For CLI or cURL, check shell access and PATH. Help choose another supported route if needed; keep verification pending when none is available. |
| 401/missing key | Check source and process access. A stale environment key overrides CLI login. Repair that source, then verify once. |
| 403 | Distinguish host policy, service access, and account restrictions from authentication. |
| 400/invalid or mismatched arguments | Fetch [SerpApi's documentation index](https://serpapi.com/llms.txt), open the selected engine's linked API page, and correct argument names, required inputs, and values before retrying. Do not reinstall or rotate credentials. |
| 429 | Check quota/throughput and retry delay; stop immediate retries. Report needed account action without purchasing credits or changing plans. |
| DNS/TLS/timeout/5xx | Check host, endpoint, proxy, and service availability. Retry once after a concrete correction or advised delay. |
| HTTP 200 with API error, malformed JSON, or empty probe | Inspect the sanitized error/structure and resolve it before claiming readiness. |

If a route is unavailable, help the user choose another supported SerpApi route. If setup is blocked or declined, explain the blocker and ask how the user wants to proceed. Leave the search pending until access works or the user explicitly chooses another provider.
