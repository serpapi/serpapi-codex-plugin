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

The agent should reuse working access or load `serpapi-setup`, verify a real search through the selected route, and resume the request. Require a nonempty organic title and link with no API error. A successful login or HTTP 200 alone is insufficient. Test the Windows helper on native Windows before claiming its dialog and DPAPI storage work.

## Build the submission archive

Create a clean ZIP with one top-level plugin directory. The `-X` flag removes macOS file attributes from the archive:

```bash
package_dir=$(mktemp -d)
(cd plugins && zip -q -r -X "$package_dir/serpapi-plugin-0.2.0.zip" serpapi \
  -x '*/__pycache__/*' '*.pyc' '*/.DS_Store')
unzip -t "$package_dir/serpapi-plugin-0.2.0.zip"
```

Upload that ZIP through the `Skills only` submission path. Keep the MIT license inside the plugin directory and do not package repository-level files beside `serpapi/`. Follow [SUBMISSION.md](SUBMISSION.md) for listing details, review cases, and release checks.

## Sync the upstream skills

Both skill directories are based on [serpapi/skills PR #7](https://github.com/serpapi/skills/pull/7) at revision [`bd619180b58faeb814ed1bc555a7a73088671809`](https://github.com/serpapi/skills/tree/bd619180b58faeb814ed1bc555a7a73088671809/skills). The PR was open when imported. Local changes in the two `SKILL.md` files clarify user-instruction precedence, scope setup to SerpApi tasks, reload credentials for each requesting process, and treat retrieved content as untrusted data. Reference edits clarify the same-call cURL requirement, credential-bearing connector URLs, and the upstream catalog link and singular headings. Credential helpers remain unchanged.

Replace both directories together when syncing a new revision, including their references and credential helpers. Remove files absent from the new source so obsolete helpers and instructions are not packaged. Preserve sibling links between `serpapi-setup` and `serpapi-web-search`, review the local changes above before replacing them, update this revision, and rerun validation. Keep upstream contributor scripts, tests, and CI configuration outside the plugin package.

Use [SerpApi's `llms.txt`](https://serpapi.com/llms.txt) as the index of published API documentation. Each linked Markdown page declares its engine identifier in its front matter and documents its required inputs. Do not infer one engine's parameters from another engine.

Make shared skill and catalog changes in [serpapi/skills](https://github.com/serpapi/skills), run its contributor checks, and sync the resulting revision here.

## Contribution workflow

1. Fork the repository.
2. Create a feature branch.
3. Make the smallest change that solves the problem.
4. Run the validation commands above.
5. Open a pull request with the validation results.
