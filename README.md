# <img src="plugins/serpapi/assets/logo.png" width="30" height="30"/> SerpApi Plugin for Codex

A Codex plugin that gives Codex the ability to search Google, Amazon, Walmart, YouTube, Google Maps, Google Scholar, and [100+ other engines](https://serpapi.com/search-engine-apis) via [SerpApi](https://serpapi.com).

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Engines](https://img.shields.io/badge/engines-107-blue.svg)](plugins/serpapi/skills/serpapi-web-search/rules/ENGINES.md)
[![MCP](https://img.shields.io/badge/MCP-SerpApi-blue.svg)](https://serpapi.com/integrations/mcp)

## Quick Start

### 1. Get an API key

Sign up at [serpapi.com](https://serpapi.com/users/sign_up) and set your API key:

```bash
export SERPAPI_KEY="your_key_here"
```

### 2. Install the plugin

Register the marketplace, then install the plugin:

```bash
codex plugin marketplace add serpapi/serpapi-codex-plugin --ref main
codex plugin add serpapi@serpapi
```

Start a new Codex thread after installation so the plugin's skills and MCP tools are loaded.

### 3. Use it

Codex will use the SerpApi skill when you ask it to search for current or web-sourced information. Just ask in natural language:

> *Search Google for the best Python web frameworks*
>
> *Compare prices for AirPods Pro on Amazon, Walmart, and eBay*
>
> *Find academic papers about transformer architectures published after 2020*

You can also explicitly ask Codex to use SerpApi:

> *Use SerpApi to search Google News for OpenAI announcements this week*

For detailed install and MCP configuration instructions, see [INSTALL.md](INSTALL.md).

## Features

- **Single skill, all engines** - `serpapi-web-search` covers SerpApi's 100+ supported engines. Codex chooses the right engine based on intent.
- **MCP-ready** - Ships a `.mcp.json` definition for SerpApi's hosted MCP server.
- **Auto-invocation** - Codex can load the search skill for research, news, shopping, maps, academic, image, video, and other web-backed requests.
- **Cost-aware defaults** - The skill defaults to `google_light` for simple web searches because it is faster and lighter than the full Google engine.
- **Fallback-friendly** - Supports MCP first, then `serpapi-cli`, SDKs, or curl when those are available.
- **Schema-guided usage** - The plugin ships engine selection guidance, parameter references, response notes, examples, and multi-engine patterns.

## Supported Engines

| Category | Engines |
|----------|---------|
| Web Search | Google, Google Light, Bing, DuckDuckGo, Yahoo, Yandex, Baidu, Naver |
| AI Search | Google AI Mode, Google AI Overview, Bing Copilot, Brave AI Mode |
| Shopping | Amazon, Walmart, eBay, Google Shopping, Home Depot |
| Local / Maps | Google Maps, Google Local, Yelp, TripAdvisor, OpenTable |
| Research | Google Scholar, Google Patents, Google Trends |
| News | Google News, Bing News, DuckDuckGo News, Baidu News |
| Media | Google Images, Google Videos, YouTube, Google Lens |
| Travel | Google Flights, Google Hotels, Google Travel Explore |
| Jobs | Google Jobs |
| Finance | Google Finance |
| Apps | Google Play, Apple App Store |

See the full list in [`plugins/serpapi/skills/serpapi-web-search/rules/ENGINES.md`](plugins/serpapi/skills/serpapi-web-search/rules/ENGINES.md).

## Troubleshooting

- **Invalid API key**: Verify your key at [serpapi.com/manage-api-key](https://serpapi.com/manage-api-key).
- **MCP tools not available**: Start a new Codex thread after installing the plugin or changing MCP configuration.
- **Plugin not listed**: Run `codex plugin marketplace list`, then reinstall with `codex plugin add serpapi@serpapi`.
- **Quota or rate limit exceeded**: Check usage in the [SerpApi dashboard](https://serpapi.com/dashboard) or review [pricing](https://serpapi.com/pricing).

## Development and Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for source installation, local validation, and contribution workflow.

## Related

- [SerpApi MCP Server](https://github.com/serpapi/serpapi-mcp) - MCP server integration for Codex, Claude Desktop, VS Code, Cursor, and other MCP-compatible clients
- [SerpApi Skills](https://github.com/serpapi/skills) - Upstream SerpApi skill source
- [SerpApi Docs](https://serpapi.com/search-api) - Full API reference
- [SerpApi Playground](https://serpapi.com/playground) - Interactive API explorer

## License

MIT License - see [LICENSE](LICENSE) file for details.
