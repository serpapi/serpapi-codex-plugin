# Installation

## GitHub Marketplace Install

```bash
codex plugin marketplace add serpapi/serpapi-codex-plugin --ref main
codex plugin add serpapi@serpapi
```

## Local Development Install

```bash
codex plugin marketplace add .
codex plugin add serpapi@serpapi
```

## SerpApi MCP Configuration

The bundled skill and MCP server configuration both use `SERPAPI_KEY`. The plugin's MCP config sends it as a bearer token to SerpApi's hosted MCP server.

```bash
export SERPAPI_KEY="your_key_here"
```

If you prefer to add the MCP server directly to Codex config, use the same secret name:

```bash
codex mcp add serpapi \
  --url https://mcp.serpapi.com/mcp \
  --bearer-token-env-var SERPAPI_KEY
```

Equivalent `config.toml`:

```toml
[mcp_servers.serpapi]
url = "https://mcp.serpapi.com/mcp"
bearer_token_env_var = "SERPAPI_KEY"
```

Start a new Codex thread after installing or changing MCP configuration.
