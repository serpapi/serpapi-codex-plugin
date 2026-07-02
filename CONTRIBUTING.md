# Contributing

Thanks for helping improve the SerpApi Codex plugin.

## Development

The plugin is packaged as a Codex marketplace repository:

```text
.agents/plugins/marketplace.json
plugins/serpapi/.codex-plugin/plugin.json
plugins/serpapi/.mcp.json
plugins/serpapi/skills/serpapi-web-search/
```

## Install From Source

From this repository root:

```bash
codex plugin marketplace add .
codex plugin add serpapi@serpapi
```

Start a new Codex thread after installation so the plugin's skills and MCP tools are loaded.

## Validate The Plugin

If you have the Codex `plugin-creator` skill installed, validate the plugin structure with:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/plugin-creator/scripts/validate_plugin.py" plugins/serpapi
```

You can also check the JSON manifests directly:

```bash
python3 -m json.tool .agents/plugins/marketplace.json
python3 -m json.tool plugins/serpapi/.codex-plugin/plugin.json
python3 -m json.tool plugins/serpapi/.mcp.json
```

## Contribution Workflow

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run validation
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request
