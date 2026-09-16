# Installation and authentication

## Install from GitHub

```bash
codex plugin marketplace add serpapi/serpapi-codex-plugin --ref main
codex plugin add serpapi@serpapi
```

## Install from a local checkout

Run these commands from the repository root:

```bash
codex plugin marketplace add .
codex plugin add serpapi@serpapi
```

After installation, start a new task in the client where the plugin is installed. For Codex CLI, start a new session.

## Configure SerpApi

Use the bundled [serpapi-setup skill](plugins/serpapi/skills/serpapi-setup/SKILL.md) to configure SerpApi. In a new task, ask:

> Use serpapi-setup to configure SerpApi and verify that search works.

You need a SerpApi account and API key. Let the setup skill guide you through the supported credential flow for your environment.

Follow the skill's prompts. It checks for existing access, guides credential setup for your environment, and verifies a real search before continuing with `serpapi-web-search`.

If access stops working in a later task or session, ask `serpapi-setup` to repair and verify the connection.
