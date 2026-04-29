#!/usr/bin/env bash
# Compare bash and Go implementations of tmux-window-status output.
# Each case: cmd|title|path. Both invocations must produce identical bytes.
set -u

cd "$(dirname "$0")"

go build -o tmux-window-status-go . || exit 1

# Test cases. Format: cmd|title|path
cases=(
    # plain shell at various paths
    "fish||$HOME"
    "fish||$HOME/bin"
    "fish||$HOME/projects/myapp"
    "fish||/tmp"
    "fish||/"
    "fish||$HOME/very-long-directory-name-here"
    "fish||/Users/riku.lindblad/projects/some-deeply-nested-thing"
    # unknown cmd falls through
    "ls||/tmp"
    "kubectl||$HOME/work"
    # known icons + path
    "git||$HOME/bin"
    "python3||$HOME/projects/myapp"
    "docker||/tmp"
    "sudo||/tmp"
    "go||$HOME/bin"
    # short-mode commands
    "nvim|file.go - NVIM|/tmp"
    "vim|vim foo.py - VIM|/tmp"
    "vi|vi /etc/hosts ~/foo|/tmp"
    "less|less /var/log/x|/tmp"
    "less|less|/tmp"
    "bat|bat foo.txt|/tmp"
    "man|man bash|/tmp"
    "cat|cat readme|/tmp"
    # special-app commands (claude/codex/pi/gemini)
    "claude|Claude Code|/tmp"
    "claude||/tmp"
    "claude|v1.2.3|/tmp"
    "codex|Codex|/tmp"
    "pi||/tmp"
    "pi|π|/tmp"
    "gemini|Gemini|/tmp"
    # wrapped via node/python with special-app title
    "node|✳ Claude Code v1.2.3|/tmp"
    "node|Codex v0.1|/tmp"
    "v1.2.3|✳ Codex|/tmp"
    "1.0.0|Gemini|/tmp"
    "python3|Claude Code|/tmp"
    # bracket title (remote-style) for various host labels
    "ssh|[hime] ~/code|/home/x"
    "ssh|[hime] vim foo|/tmp"
    "ssh|[hime] git status|/tmp"
    "ssh|[prox] less /var/log/x|/tmp"
    "ssh|[orochi] |/tmp"
    "ssh|[unknown] ls|/tmp"
    "ssh|[hime]|/tmp"
    "fish|[prox] git log|/tmp"
    "fish|[hime] vim foo|/tmp"
    # ssh remote-mode (no bracket in title)
    "ssh|user@host|/tmp"
    "ssh|ssh [hime] /home/x|/tmp"
    "ssh|ssh hime - SSH|/tmp"
    "ssh|hime|/tmp"
    "ssh||/tmp"
    # scp variants
    "scp|[hime] /tmp/x|/tmp"
    # version-like title with special app fallback
    "v1.2.3-beta|Claude Code|/tmp"
    # brackets with embedded short-mode cmd
    "ssh|[hime] man bash|/tmp"
    "ssh|[hime] bat foo.txt|/tmp"
)

fail=0
pass=0
for c in "${cases[@]}"; do
    IFS='|' read -r cmd title path <<< "$c"
    bash_out=$(./tmux-window-status "$cmd" "$title" "$path")
    go_out=$(./tmux-window-status-go "$cmd" "$title" "$path")
    if [[ "$bash_out" != "$go_out" ]]; then
        printf 'MISMATCH: cmd=%q title=%q path=%q\n' "$cmd" "$title" "$path"
        printf '  bash: %s\n' "$bash_out"
        printf '  go:   %s\n' "$go_out"
        fail=$((fail+1))
    else
        printf 'OK [%s] → %s\n' "$c" "$bash_out"
        pass=$((pass+1))
    fi
done

echo
echo "passed: $pass  failed: $fail"
exit $fail
