# Request and response gotchas

Use the engine's current MCP resource (`serpapi://engines/<engine>`) when available, otherwise its [official documentation link](engines.md). The Search tool's generic parameter object does not describe every engine's requirements.

## Query and time filters

Do not substitute `q` for every engine's input: YouTube uses `search_query`, Amazon `k`, eBay `_nkw`, App Store `term`, and Facebook/Instagram profiles `profile_id`. Scholar Author uses `author_id`. Maps reviews require a place identifier, not a keyword. Required inputs appear in the engine index.

| Engine | Time filter | Values |
|---|---|---|
| `google_light` | `as_qdr` | `d`, `w`, `m`, `y`; append a number, such as `w2` |
| `google` | `tbs` | `qdr:d`, `qdr:w`, `qdr:m`, `qdr:y` |

Resolve place names with the [Locations API](https://serpapi.com/locations-api) when a locale is ambiguous. For Maps, put the city in the query or use `ll`; a map center does not guarantee every result lies within a specific boundary.

## Output and pagination by route

| Route | Response handling |
|---|---|
| MCP | Use JSON for field extraction, Markdown for reading. The current server accepts `output=json` or `output=md`, not HTML. Tool content can be a JSON string or a plain-text error; check both content and MCP error status. |
| CLI | Use embedded `--jq` for extraction and `--fields` for server filtering. Check the process status before trusting output. |
| cURL / REST | JSON is suitable for extraction; REST also supports HTML and Markdown. Keep the setup guide's safe credential transport and check HTTP status plus the body. |

`mode="compact"` removes `search_metadata`, `search_parameters`, `search_information`, `pagination`, and `serpapi_pagination`. Use complete MCP responses when you need the search ID or pagination; retain only needed fields in notes afterward. `json_restrictor` and CLI `--fields` can also remove fields you later need.

For manual pagination, inspect `serpapi_pagination.next` or the engine's next-page token. Validate that a next URL is an HTTPS SerpApi Search API URL, then carry its query parameters into the next request through the same route. Keep authentication in the selected credential source, and preserve required response filters that the next URL may omit. Never pass a URL as the MCP `params` object or assume every engine uses `start`.

For CLI pagination, use `--all-pages` with an explicit `--max-pages` within the user's search budget. The CLI merges result arrays; this can produce a large response. Stop when pagination is absent, repeats, or reaches the chosen limit.

## Conditional result sections

- Maps can return `place_results` or `local_results`. Inspect both before selecting a business; confirm the returned name and location before extracting contact details or a `data_id`.
- Flights can return `best_flights`, `other_flights`, or both. Combine available groups. Use future dates; one-way requests use `type=2`, while round trips also require `return_date`.
- Google Shopping aggregates retailer feeds; cross-check the retailer's current page when the task needs its exact price. Use `google_light` with a retailer `site:` query to find it.
- Scholar Author returns a page of publications, not necessarily the full list. Follow pagination when a complete bibliography is requested. See [Scholar Author documentation](https://serpapi.com/google-scholar-author-api.md).
- Empty results for a valid task query do not by themselves imply broken authentication. Setup uses a known general probe when it needs to distinguish these cases.

## Cache, archive, and incompatible options

Keep caching enabled unless the task requires a fresh crawl. An identical cached query can be free within one hour; `no_cache=true` forces a new search. Reducing response size does not reduce the number of searches. Only successful searches count toward the search quota. See [Search API behavior](https://serpapi.com/search-api).

Do not combine `no_cache=true` with `async=true`. Async submission is not supported for accounts with [Ludicrous Speed](https://serpapi.com/ludicrous-speed). ZeroTrace disables server-side retention; do not promise archive recovery for those requests.

Save the search ID when later archive access matters, using a complete response. The [Archive API](https://serpapi.com/search-archive-api) can retrieve retained searches for up to 31 days. Through the CLI, use `serpapi archive "$SEARCH_ID"`; through cURL, use the archive endpoint with the same protected credential method. A search-only MCP connection does not imply an archive tool exists.

On quota, transport, API, or tool failures, consult [serpapi-setup](../../serpapi-setup/SKILL.md) and follow its repair path. Keep the original route and task attached to the diagnostic.
