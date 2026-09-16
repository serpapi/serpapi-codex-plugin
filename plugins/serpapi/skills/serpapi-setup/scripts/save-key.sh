#!/usr/bin/env bash
# Store a key outside Git worktrees without exposing it in arguments or output.
set +x
set -euo pipefail
umask 077

fail() { printf '%s\n' "$1" >&2; exit 1; }
[[ $# -eq 0 ]] || fail 'This script takes no arguments. Use its hidden prompt or SERPAPI_KEY.'

serpapi_config="${XDG_CONFIG_HOME:-$HOME/.config}"
[[ "$serpapi_config" = /* ]] || fail 'The config directory must be an absolute path.'
case "$serpapi_config/" in */../*|*/./*) fail 'Use a config path without dot components.' ;; esac
[[ ! -L "$serpapi_config" ]] || fail 'Refusing a symlinked config directory.'

# Resolve existing ancestors before testing the eventual destination.
serpapi_parent="$serpapi_config"
serpapi_suffix=''
while [[ ! -e "$serpapi_parent" && ! -L "$serpapi_parent" ]]; do
    serpapi_suffix="/${serpapi_parent##*/}$serpapi_suffix"
    serpapi_parent="${serpapi_parent%/*}"
    [[ -n "$serpapi_parent" ]] || serpapi_parent=/
done
[[ -d "$serpapi_parent" && -O "$serpapi_parent" ]] || fail 'The existing config parent must be a directory owned by the current user.'
serpapi_parent="$(cd -P "$serpapi_parent" && pwd -P)"
serpapi_mode="$(stat -c '%a' "$serpapi_parent" 2>/dev/null || stat -f '%Lp' "$serpapi_parent")"
[[ "$serpapi_mode" =~ ^[0-7]+$ ]] || fail 'Cannot verify config-parent permissions.'
(( (8#$serpapi_mode & 0022) == 0 )) || fail 'The config parent must not be writable by other users.'
serpapi_config="${serpapi_parent%/}$serpapi_suffix"
serpapi_dir="$serpapi_config/serpapi"
serpapi_ancestor="$serpapi_dir"
while :; do
    [[ ! -e "$serpapi_ancestor/.git" && ! -L "$serpapi_ancestor/.git" ]] || fail 'Refusing to store a key inside a Git worktree.'
    [[ "$serpapi_ancestor" != / ]] || break
    serpapi_ancestor="${serpapi_ancestor%/*}"
    [[ -n "$serpapi_ancestor" ]] || serpapi_ancestor=/
done
[[ ! -L "$serpapi_dir" ]] || fail 'Refusing a symlinked SerpApi directory.'
if [[ -e "$serpapi_dir" ]]; then
    [[ -d "$serpapi_dir" && -O "$serpapi_dir" ]] || fail 'The SerpApi directory must belong to the current user.'
fi
serpapi_file="$serpapi_dir/api_key"
[[ ! -e "$serpapi_file" && ! -L "$serpapi_file" ]] || fail 'A stored key already exists. Reuse it or explicitly rotate it.'

serpapi_key="${SERPAPI_KEY:-}"
if [[ -z "$serpapi_key" ]]; then
    serpapi_tty_state="$(stty -g </dev/tty)" || fail 'Use an interactive terminal or inject SERPAPI_KEY.'
    trap 'stty "$serpapi_tty_state" </dev/tty; unset serpapi_key' EXIT
    trap 'exit 130' INT
    trap 'exit 143' HUP TERM
    # Disable echo before displaying the prompt, including for fast pasted input.
    stty -echo </dev/tty
    printf 'SerpApi API key: ' >&2
    IFS= read -r serpapi_key </dev/tty || fail 'Could not read the key.'
    stty "$serpapi_tty_state" </dev/tty
    trap - EXIT INT HUP TERM
    printf '\n' >&2
fi
[[ -n "$serpapi_key" && "$serpapi_key" != *[[:space:]]* ]] || fail 'The key must be nonempty and contain no whitespace.'

mkdir -p "$serpapi_dir"
chmod 700 "$serpapi_dir"
serpapi_temp="$(mktemp "$serpapi_dir/.api_key.XXXXXX")"
trap 'rm -f "$serpapi_temp"; unset serpapi_key' EXIT
chmod 600 "$serpapi_temp"
printf '%s' "$serpapi_key" > "$serpapi_temp"
# Linking in the same private directory fails atomically if the key now exists.
ln "$serpapi_temp" "$serpapi_file"
printf 'Saved key to %s (directory 700, file 600; plaintext). Verify access before use.\n' "$serpapi_file"
