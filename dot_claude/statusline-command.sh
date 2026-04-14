#!/bin/sh
# Claude Code status line - mirrors Starship prompt style
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // .model.id')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Replace $HOME prefix with ~
case "$cwd" in
  "$HOME") display_dir="~" ;;
  "$HOME"/*) display_dir="~${cwd#"$HOME"}" ;;
  *) display_dir="$cwd" ;;
esac

# SSH hostname prefix
ssh_info=""
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  ssh_info="on $(hostname -s) "
fi

# Git branch and status
git_info=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  ahead=$(git -C "$cwd" rev-list --count @{u}..HEAD 2>/dev/null || echo "")
  behind=$(git -C "$cwd" rev-list --count HEAD..@{u} 2>/dev/null || echo "")

  git_info=" [$branch"
  if [ -n "$ahead" ] && [ "$ahead" -gt 0 ] 2>/dev/null && [ -n "$behind" ] && [ "$behind" -gt 0 ] 2>/dev/null; then
    git_info="$git_info ⇕⇡${ahead}⇣${behind}"
  elif [ -n "$ahead" ] && [ "$ahead" -gt 0 ] 2>/dev/null; then
    git_info="$git_info ⇡${ahead}"
  elif [ -n "$behind" ] && [ "$behind" -gt 0 ] 2>/dev/null; then
    git_info="$git_info ⇣${behind}"
  fi
  git_info="$git_info]"
fi

# Context usage
ctx=""
if [ -n "$used" ]; then
  ctx=" ctx:$(printf '%.0f' "$used")%"
fi

printf "\033[0;32m%s\033[0m\033[0;34m%s\033[0m\033[0;33m%s\033[0m \033[0;37m%s%s\033[0m" \
  "$ssh_info" "$display_dir" "$git_info" "$model" "$ctx"
