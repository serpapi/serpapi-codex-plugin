# <img src="plugins/serpapi/assets/logo.png" width="30" height="30"/> SerpApi for ChatGPT and Codex

Search current results from [SerpApi's 100+ engines](https://serpapi.com/llms.txt). This skills-only plugin includes `serpapi-setup` and `serpapi-web-search`, adapted from SerpApi's upstream skills. They configure access and search through MCP, CLI, or raw cURL. The package does not include an MCP server.

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Plugin](https://img.shields.io/badge/plugin-skills--only-blue.svg)](plugins/serpapi/.codex-plugin/plugin.json)

## Install

After publication, you can install SerpApi from the Plugin Directory in ChatGPT or Codex. The GitHub commands below install the version currently published on `main`. To test local changes before publication, use the local-checkout commands instead:

```bash
codex plugin marketplace add serpapi/serpapi-codex-plugin --ref main
codex plugin add serpapi@serpapi
```

To test a local checkout, run these commands from the repository root:

```bash
codex plugin marketplace add .
codex plugin add serpapi@serpapi
```

After installation, start a new task in the client where the plugin is installed. For Codex CLI, start a new session.

## Authenticate

Ask the agent:

> Set up SerpApi, verify access, and then search for recent OpenAI announcements.

Follow the bundled [serpapi-setup skill](plugins/serpapi/skills/serpapi-setup/SKILL.md) to configure and verify access. A SerpApi account and API key are required. See [INSTALL.md](INSTALL.md) for installation and guided setup.

The execution environment needs a working SerpApi MCP connection or a shell with HTTPS access for CLI or cURL. Installing the skills does not add shell access or an MCP connection to a client that lacks them.

## Use

Ask in natural language. For example:

> Use SerpApi to find the latest OpenAI announcements and cite the strongest sources.

> Compare current AirPods Pro listings on Amazon, Walmart, and eBay.

> Find recent papers about retrieval-augmented generation in Google Scholar.

The skill uses `google_light` for general web research. It selects a specialized engine when the request involves news, images, shopping, maps, academic papers, travel, finance, products, or reviews.

## How it works

- The `serpapi-setup` skill detects the environment, configures access, and verifies a real search.
- The `serpapi-web-search` skill selects an engine and reuses the verified MCP, CLI, or cURL route.
- Engine and parameter guidance comes from the API pages in [SerpApi's `llms.txt`](https://serpapi.com/llms.txt).
- Search recipes cover field selection, pagination, and source links.

## Authentication limits

Missing access starts guided setup. The skill checks the selected route's credential source, verifies a real request, and retries the original search. A working MCP connection needs no local key copy. If setup is blocked, the search stays pending until access is ready or you explicitly choose another provider.

Use `serpapi-setup` to configure or repair credentials for the current environment. Do not paste an API key into ordinary chat or a repository file.

## Documentation

- [Installation and authentication](INSTALL.md)
- [Setup skill](plugins/serpapi/skills/serpapi-setup/SKILL.md)
- [Search skill](plugins/serpapi/skills/serpapi-web-search/SKILL.md)
- [Supported engines](plugins/serpapi/skills/serpapi-web-search/references/engines.md)
- [Request and response gotchas](plugins/serpapi/skills/serpapi-web-search/references/gotchas.md)
- [Search recipes](plugins/serpapi/skills/serpapi-web-search/references/recipes.md)
- [SerpApi API index](https://serpapi.com/llms.txt)

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for validation and source-install instructions.

## Support

Contact [SerpApi support](https://serpapi.com/#contact) for account or search issues. Report plugin issues in the [GitHub repository](https://github.com/serpapi/serpapi-codex-plugin/issues).

## License

MIT. See [LICENSE](LICENSE).
