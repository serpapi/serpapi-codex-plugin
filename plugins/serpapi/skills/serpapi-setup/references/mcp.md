# MCP setup

Use an existing SerpApi connection first. Otherwise confirm the **target client** supports remote Streamable HTTP or a supported local extension. Browser-only chats, remote connectors, and terminal agents have different setup interfaces. A skill cannot add MCP capabilities to a host that does not expose them.

The [SerpApi server](https://github.com/serpapi/serpapi-mcp#authentication) accepts `Authorization: Bearer` at `https://mcp.serpapi.com/mcp`. Prefer this endpoint with a client-managed secret or environment reference. Do not assume that `serpapi login` configures MCP, or that this API-key service supports an OAuth login flow.

For environment references, load `SERPAPI_KEY` from [credentials.md](credentials.md) into the process that starts the MCP client. A fresh export in an agent's shell cannot change the environment of its already-running parent application. Restart/relaunch as needed, then verify in that client.

## Codex

Check the installed `codex mcp add --help`. For versions supporting bearer-token environment references:

```bash
codex mcp add serpapi --url https://mcp.serpapi.com/mcp --bearer-token-env-var SERPAPI_KEY
```

The corresponding user configuration is:

```toml
[mcp_servers.serpapi]
url = "https://mcp.serpapi.com/mcp"
bearer_token_env_var = "SERPAPI_KEY"
```

Merge only this server into the existing config. For desktop clients that cannot inherit the secret, use their supported credential setup or header-helper mechanism after checking the installed version. Do not silently replace the environment reference with a literal key. See [Codex MCP documentation](https://learn.chatgpt.com/docs/extend/mcp?surface=cli).

## Claude Code

Add a user-scoped server using a literal environment reference. The single quotes prevent the shell from expanding the key into command arguments:

```bash
claude mcp add-json --scope user serpapi '{"type":"http","url":"https://mcp.serpapi.com/mcp","headers":{"Authorization":"Bearer ${SERPAPI_KEY}"}}'
```

Load the variable before launching Claude Code. Check `/mcp` in the target session, then call the tool. See [Claude Code MCP configuration](https://code.claude.com/docs/en/mcp).

## Cursor

Merge into user-level `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "serpapi": {
      "url": "https://mcp.serpapi.com/mcp",
      "headers": {"Authorization": "Bearer ${env:SERPAPI_KEY}"}
    }
  }
}
```

Cursor's environment syntax differs from Claude Code's. Remote MCP does not support Cursor's stdio `envFile` setting. See [Cursor MCP configuration](https://cursor.com/docs/mcp).

## VS Code Copilot

Use **MCP: Add Server**, select HTTP, and use the hosted endpoint. Follow [VS Code's MCP instructions](https://code.visualstudio.com/docs/agent-customization/mcp-servers) for a password input variable referenced by the Authorization header, or an environment reference available to the client. Store the entry at user scope unless the user requests project scope. VS Code's config uses `servers`, not Cursor's `mcpServers`; do not paste one client's wrapper into another.

For VS Code's built-in chat, merge this into **MCP: Open User Configuration**:

```json
{
  "inputs": [
    {"type":"promptString","id":"serpapi-key","description":"SerpApi API key","password":true}
  ],
  "servers": {
    "serpapi": {
      "type":"http",
      "url":"https://mcp.serpapi.com/mcp",
      "headers":{"Authorization":"Bearer ${input:serpapi-key}"}
    }
  }
}
```

VS Code's Agent Host sessions do not receive servers requiring interactive inputs. For those sessions, follow the [configuration reference](https://code.visualstudio.com/docs/agents/reference/mcp-configuration) for their native configuration and secret mechanism; verify in that session instead of assuming a built-in chat connection applies.

## Claude Desktop and URL-only connectors

For Claude Desktop, the SerpApi [MCP bundle](https://github.com/serpapi/serpapi-mcp#claude-desktop-extension-mcp-bundle) offers a local extension with a sensitive API-key input. Use the official release and supported extension UI; this route provisions a local runtime.

For a remote connector, use [Customize > Connectors > Add custom connector](https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp). If its current UI only accepts a URL, SerpApi supports `https://mcp.serpapi.com/your_key_here/mcp`. Explain that the URL contains the secret and may persist in the client's connector configuration, then have the user enter it directly in the connector UI. Never put the completed URL in chat, repository files, or shell arguments. Do not use a local JSON file to configure Claude's remote connector, which runs in the cloud.

## Other clients

Use the client's current official MCP instructions to establish its transport, configuration scope, secret-input mechanism, and reload behavior. Do not infer support from skill support or guess a JSON format. If no supported path can be established, offer CLI or cURL when a shell is available.

## Verify in the client

After any reload, discover the SerpApi `search` tool and call it with `params={"engine":"google_light","q":"coffee"}` and `mode="compact"`, adapting to the discovered schema. Check both MCP error status and the returned API data. Require a result with a title and link. Registration, tool listing, an HTTP initialization response, or a successful CLI request does not complete MCP verification. If a fresh session is necessary, state that verification must finish there.
