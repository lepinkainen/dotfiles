#!/bin/sh
set -e

echo "Installing llm plugins..."

if ! command -v llm >/dev/null 2>&1; then
    echo "Error: llm is not installed."
    echo "Install it via 'brew install llm' first."
    exit 1
fi

echo "Installing llm-claude..."
llm install llm-claude || echo "Warning: Failed to install llm-claude"

echo "Installing llm-ollama..."
llm install llm-ollama || echo "Warning: Failed to install llm-ollama"

echo "Installing llm-gemini..."
llm install llm-gemini || echo "Warning: Failed to install llm-gemini"

echo ""
echo "Installed plugins:"
llm plugins
