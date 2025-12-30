#!/usr/bin/env bash
set -euo pipefail

llm_plugins=(
    llm-anthropic
    llm-cmd
    llm-fragments-github
    llm-fragments-reader
    llm-fragments-youtube
    llm-gemini
    llm-github-copilot
    llm-hacker-news
    llm-openai-plugin
)

llm_with_args=()
for plugin in "${llm_plugins[@]}"; do
    llm_with_args+=("--with" "$plugin")
done
echo "Installing llm with plugins: ${llm_plugins[*]}"

uv tool install --reinstall -U llm "${llm_with_args[@]}"


TEMPLATES_PATH=$(llm templates path 2>/dev/null || echo "")
if [[ -z "${TEMPLATES_PATH}" ]]; then
    echo "Error: Unable to determine llm templates path" >&2
    exit 1
fi

# Create datasette llm config directory and symlink templates
mkdir -p "${HOME}/.config/io.datasette.llm"
# Easier way to access the template directory
ln -sfh "${TEMPLATES_PATH}" "${HOME}/.config/io.datasette.llm/templates"
