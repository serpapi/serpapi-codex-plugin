# Search recipes

Run these requests through the route verified by `serpapi-setup`. The JSON objects are engine parameters: place them inside MCP `params`, translate them to CLI `name=value` arguments, or to cURL `--data-urlencode` arguments using the setup guide. CLI-only examples apply when CLI was selected; they are not a reason to install it or change routes.

## Nonstandard inputs

```json
{"engine":"youtube","search_query":"machine learning tutorial"}
```

```json
{"engine":"amazon","k":"wireless headphones"}
```

```json
{"engine":"ebay","_nkw":"vintage watch"}
```

These return `video_results`, `organic_results`, and `organic_results`, respectively. For other engines, use the [engine index](engines.md).

## Filter before retaining results

In any route, `json_restrictor` selects fields on the server. Retain the result fields needed by the task plus metadata required for pagination, diagnosis, or archive access.

```json
{"engine":"google_light","q":"coffee","json_restrictor":"organic_results[0:5].title,organic_results[0:5].link,organic_results[0:5].snippet"}
```

In CLI sessions, combine `--fields` with the embedded jq processor:

```bash
serpapi search engine=google_light q=coffee --fields 'organic_results[0:5]' --jq '[.organic_results[] | {title, link, snippet}]'
```

For cURL, retain the setup guide's stdin/file authentication. Add `json_restrictor` to that request; do not put the key in command arguments or install jq for a cURL-only setup.

## Find a business, then read its reviews

```json
{"engine":"google_maps","type":"search","q":"The French Laundry Yountville California"}
```

Inspect `place_results` and `local_results`, select the matching business, and retain its `data_id`. Use that value in the next request:

```json
{"engine":"google_maps_reviews","data_id":"<selected business data_id>","sort_by":"newestFirst"}
```

For CLI extraction, handle either Maps response before selecting an entry:

```bash
serpapi search engine=google_maps type=search q='The French Laundry Yountville California' --jq '(if .place_results then [.place_results] else (.local_results // []) end) | map({title, address, phone, rating, reviews, data_id})'
```

## Follow an AI Overview token immediately

```json
{"engine":"google","q":"what is serpapi"}
```

Inspect `ai_overview`. Use an included answer directly. When it contains `page_token`, pass it immediately to `google_ai_overview`; the token expires within one minute. If neither an overview nor a token is returned, report its absence. See the [official token flow](https://serpapi.com/google-ai-overview-api).

```json
{"engine":"google_ai_overview","page_token":"<ai_overview.page_token>"}
```

## Extract both flight groups

Use a future outbound date. In a CLI session:

```bash
serpapi search engine=google_flights departure_id=JFK arrival_id=LAX outbound_date=YYYY-MM-DD type=2 --jq '((.best_flights // []) + (.other_flights // [])) | map({price, airline: .flights[0].airline})'
```

## Combine independent searches within a budget

Choose engines for the task: finance data plus relevant news, or a retailer search plus shopping comparisons. A generic research request does not automatically need several engines. When quota is uncertain, consult setup and validate the account response before starting new calls. If that check fails, stop rather than interpreting missing quota as sufficient quota.

Use the host's parallel tool support when available and inspect every result. For a two-call CLI plan already within the user's budget, this Bash example preserves each status and separates outputs. The temporary responses are private and removed on success or failure:

```bash
(
  umask 077
  serpapi_run_dir="$(mktemp -d "${TMPDIR:-/tmp}/serpapi-research.XXXXXX")" || exit 1
  trap 'rm -rf -- "$serpapi_run_dir"' EXIT
  serpapi search engine=google_finance q='AAPL:NASDAQ' --jq '{summary}' > "$serpapi_run_dir/finance.json" &
  serpapi_finance_pid=$!
  serpapi search engine=google_news_light q='Apple earnings' --jq '{news_results}' > "$serpapi_run_dir/news.json" &
  serpapi_news_pid=$!
  serpapi_failed=0
  wait "$serpapi_finance_pid" || serpapi_failed=1
  wait "$serpapi_news_pid" || serpapi_failed=1
  if [ "$serpapi_failed" -ne 0 ]; then
    printf 'A search failed; consult serpapi-setup before retrying.\n' >&2
    exit 1
  fi
  printf 'Finance response:\n'
  cat "$serpapi_run_dir/finance.json"
  printf '\nNews response:\n'
  cat "$serpapi_run_dir/news.json"
)
```

Extract findings after each request. Keep the source URL, relevant fields, and search ID when available, so later reasoning does not depend on raw responses remaining in context.
