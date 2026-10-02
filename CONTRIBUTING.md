# Contributing

The repository packages a skills-only plugin:

```text
.agents/plugins/marketplace.json
plugins/serpapi/.codex-plugin/plugin.json
plugins/serpapi/LICENSE
plugins/serpapi/assets/
plugins/serpapi/skills/serpapi-setup/
plugins/serpapi/skills/serpapi-web-search/
```

## Install from source

From the repository root:

```bash
codex plugin marketplace add .
codex plugin add serpapi@serpapi
```

After installation, start a new task in the client where the plugin is installed. For Codex CLI, start a new session.

## Validate

If your Codex installation includes the `plugin-creator` and `skill-creator` system skills, run their validators:

```bash
uv run --with pyyaml python "${CODEX_HOME:-$HOME/.codex}/skills/.system/plugin-creator/scripts/validate_plugin.py" plugins/serpapi
uv run --with pyyaml python "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" plugins/serpapi/skills/serpapi-setup
uv run --with pyyaml python "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" plugins/serpapi/skills/serpapi-web-search
```

Check the manifests and POSIX credential helper:

```bash
uv run python -m json.tool .agents/plugins/marketplace.json >/dev/null
uv run python -m json.tool plugins/serpapi/.codex-plugin/plugin.json >/dev/null
bash -n plugins/serpapi/skills/serpapi-setup/scripts/save-key.sh
```

In a fresh task, test setup and search:

> Use SerpApi to search Google Light for coffee.

The agent should reuse working access or load `serpapi-setup`, verify a real search through the selected route, and resume the request. Require a nonempty organic title and link with no API error.

## Build the submission archive

Create a clean ZIP with one top-level plugin directory. The `-X` flag removes macOS file attributes from the archive:

```bash
package_dir=$(mktemp -d)
(cd plugins && zip -q -r -X "$package_dir/serpapi-plugin-0.2.0.zip" serpapi \
  -x '*/__pycache__/*' '*.pyc' '*/.DS_Store')
unzip -t "$package_dir/serpapi-plugin-0.2.0.zip"
```

Upload that ZIP through the `Skills only` submission path. Keep the MIT license inside the plugin directory and do not package repository-level files beside `serpapi/`.

## SerpApi Engines Source of Truth


Use [SerpApi's `llms.txt`](https://serpapi.com/llms.txt) as the index of published API documentation. Each linked Markdown page declares its engine identifier in its front matter and documents its required inputs. Do not infer one engine's parameters from another engine.


## Contribution workflow

1. Fork the repository.
2. Create a feature branch.
3. Make the smallest change that solves the problem.
4. Run the validation commands above.
5. Open a pull request with the validation results.
