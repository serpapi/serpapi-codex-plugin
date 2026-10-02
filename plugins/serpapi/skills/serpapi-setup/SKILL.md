---
name: serpapi-setup
description: Guide the user through SerpApi setup or repair when first used, unconfigured, missing a key or executable, or failing requests. Detect the shell environment, reuse access or help choose CLI or raw cURL, collect credentials securely, and verify a real search before resuming the task with SerpApi.
license: MIT
---

## Identify and choose

1. Tell the user you will help configure SerpApi and then resume their task. Identify the client, OS, shell, and execution host from the session; ask only for missing context. Local apps, WSL, containers, and remote hosts can have different credentials and network access.
2. Confirm shell access, then check for `serpapi`, `curl` (`curl.exe` in PowerShell), and credential presence, including the chosen route's [stored source](references/credentials.md). This plugin requires a shell and HTTPS access to `serpapi.com`. If the host cannot run commands, explain that setup needs a shell-enabled environment and leave verification pending. An unset `SERPAPI_KEY` alone does not prove a key is unavailable. Never print credentials; config presence does not prove connectivity.
3. Reuse working access or honor the user's selected route. Otherwise explain the available choices below, recommend one that fits, and ask their preference. Carry out the chosen setup within existing authorization; do not stop at a menu or tell them to configure it themselves.

| Route | Requirements | Guide |
|---|---|---|
| CLI | Shell, user wants the command interface, HTTPS access to `serpapi.com` | [CLI](references/cli.md) |
| Raw cURL | Existing curl, HTTPS access to `serpapi.com`; no additional packages | [cURL](references/curl.md) |

Read the chosen guide and relevant credential section. For no additional packages, use existing cURL; do not install Python, Node.js, jq, or a package manager. Keep working SDK integrations in their runtime when the user explicitly requests them.

This workflow applies to SerpApi setup and repair. Follow the user's explicit instructions over its defaults. Keep the SerpApi request pending during setup and ask before substituting another provider. For a failed request, diagnose below while retaining the route and original task.

## Configure

For a missing key, share the [dashboard](https://serpapi.com/dashboard) and explain where to enter it. Use the client's secret field, an interactive hidden prompt, or the [Windows password-dialog helper](references/credentials.md#windows-encrypted-storage). Never request the key in chat or put it in commands, history, or workspace files. Launch the actual prompt and confirm completion; an empty terminal window is not a prompt.

Preserve existing credentials and their scope. If input, approval, or a restart is required, give the exact next action and wait for it; silence is not completion. Reload the stored key in the same process as each CLI or cURL request; never assume an earlier tool call's export persists. Keep verification pending while blocked; do not replace keys, disable TLS verification, or bypass host policy.

## Verify and resume

Make one small real search with `engine=google_light`, `q=coffee`, or the original task's valid request. It may use one credit. Do not force a fresh crawl, paginate, or test every route by default.

1. Verify **through the selected route**: CLI executable/account then search; cURL HTTP status and JSON body. Run the request on the host that will perform subsequent searches.
2. Require transport/process success, and no API `error`. HTTP 200, exit code 0, or login alone is insufficient. The coffee probe must return a nonempty organic title and link. Empty results from another query are inconclusive; use the probe if needed.
3. After repair, repeat the corrected original operation through the same route. A passing probe with a failing task means access works but the task remains unresolved.
4. Report the route, execution host, credential source/location without its value, checks passed, and anything pending. Keep the retrieval method available for future sessions; do not write a permanent verified flag.
5. Resume [serpapi-web-search](../serpapi-web-search/SKILL.md), discovering it by name if the sibling link is unavailable. If live calls are disallowed or results cannot be inspected, report verification pending.

## Diagnose failures

Retain the engine, route, sanitized error, and original task. Stay here until verification succeeds or a specific blocker is established.

| Failure | Action |
|---|---|
| Missing shell/executable | Confirm the execution host supports shell commands, then check PATH and the chosen route's install guide. Keep verification pending when shell access is unavailable. |
| 401/missing key | Check source and process access. A stale environment key overrides CLI login. Repair that source, then verify once. |
| 403 | Distinguish host policy, service access, and account restrictions from authentication. |
| 400/invalid or mismatched arguments | Fetch [SerpApi's documentation index](https://serpapi.com/llms.txt), open the selected engine's linked API page, and correct argument names, required inputs, and values before retrying. Do not reinstall or rotate credentials. |
| 429 | Check quota/throughput and retry delay; stop immediate retries. Report needed account action without purchasing credits or changing plans. |
| DNS/TLS/timeout/5xx | Check host, endpoint, proxy, and service availability. Retry once after a concrete correction or advised delay. |
| HTTP 200 with API error, malformed JSON, or empty probe | Inspect the sanitized error/structure and resolve it before claiming readiness. |

If a route is unavailable, help the user choose another supported SerpApi route. If setup is blocked or declined, explain the blocker and ask how the user wants to proceed. Leave the search pending until access works or the user explicitly chooses another provider.
