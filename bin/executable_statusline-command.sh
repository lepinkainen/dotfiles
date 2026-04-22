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

# Context usage progress bar (20 steps)
ctx=""
if [ -n "$used" ]; then
  pct=$(printf '%.0f' "$used")
  filled=$(( pct * 20 / 100 ))
  [ "$filled" -gt 20 ] && filled=20
  [ "$filled" -lt 0 ] && filled=0
  empty=$(( 20 - filled ))
  bar=""
  i=0; while [ "$i" -lt "$filled" ]; do bar="${bar}█"; i=$((i+1)); done
  i=0; while [ "$i" -lt "$empty" ]; do bar="${bar}░"; i=$((i+1)); done
  # Color: green <50%, yellow 50-79%, red 80%+
  if [ "$pct" -ge 80 ]; then
    color="0;31"
  elif [ "$pct" -ge 50 ]; then
    color="0;33"
  else
    color="0;32"
  fi
  ctx=" \033[${color}m[${bar}]\033[0m ${pct}%"
fi

# Caveman mode badge
caveman=""
CAVEMAN_FLAG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
if [ ! -L "$CAVEMAN_FLAG" ] && [ -f "$CAVEMAN_FLAG" ]; then
  cmode=$(head -c 64 "$CAVEMAN_FLAG" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]')
  cmode=$(printf '%s' "$cmode" | tr -cd 'a-z0-9-')
  case "$cmode" in
    off|lite|full|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra|commit|review|compress)
      if [ -z "$cmode" ] || [ "$cmode" = "full" ]; then
        caveman=" \033[38;5;172m[CAVEMAN]\033[0m"
      else
        caveman=" \033[38;5;172m[CAVEMAN:$(printf '%s' "$cmode" | tr '[:lower:]' '[:upper:]')]\033[0m"
      fi
      ;;
  esac
fi

printf "\033[0;32m%s\033[0m\033[0;34m%s\033[0m\033[0;33m%s\033[0m \033[0;37m%s\033[0m%b%b" \
  "$ssh_info" "$display_dir" "$git_info" "$model" "$ctx" "$caveman"
