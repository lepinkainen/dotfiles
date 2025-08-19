#!/bin/bash
# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Get current working directory for git operations
cd "$CURRENT_DIR" 2>/dev/null

# Username (show always like your Starship config)
USERNAME=$(whoami)

# Hostname (SSH detection like Starship)
HOSTNAME_PART=""
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    HOSTNAME_PART="on $(hostname -s) "
fi

# Directory with truncation (like Starship config with length 8)
DIR_NAME="${CURRENT_DIR##*/}"
if [ ${#DIR_NAME} -gt 20 ]; then
    DIR_NAME="…${DIR_NAME: -17}"
fi

# Git status with symbols like your Starship config
GIT_INFO=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        # Get git status
        STATUS=""
        
        # Check for ahead/behind
        AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
        BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
        
        if [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -gt 0 ]; then
            STATUS="⇕⇡${AHEAD}⇣${BEHIND}"
        elif [ "$AHEAD" -gt 0 ]; then
            STATUS="⇡${AHEAD}"
        elif [ "$BEHIND" -gt 0 ]; then
            STATUS="⇣${BEHIND}"
        fi
        
        # Add branch and status
        GIT_INFO=" 🌿 $BRANCH"
        if [ -n "$STATUS" ]; then
            GIT_INFO="$GIT_INFO $STATUS"
        fi
    fi
fi

# Battery status (like Starship config)
BATTERY=""
if command -v pmset >/dev/null 2>&1; then
    BATTERY_PCT=$(pmset -g batt | grep -o "[0-9]*%" | head -1 | tr -d '%')
    IS_PLUGGED_IN=$(pmset -g batt | grep -q "AC Power" && echo "yes" || echo "no")
    
    if [ -n "$BATTERY_PCT" ] && [ "$BATTERY_PCT" -lt 100 ] && [ "$IS_PLUGGED_IN" = "no" ]; then
        if [ "$BATTERY_PCT" -le 20 ]; then
            BATTERY=" ⚡${BATTERY_PCT}%"
        else
            BATTERY=" 🔋${BATTERY_PCT}%"
        fi
    fi
fi

# Claude usage status from ccusage with formatting improvements
CCUSAGE=""
if command -v bun >/dev/null 2>&1; then
    CCUSAGE_RAW=$(echo "$input" | bun x ccusage statusline 2>/dev/null)
    if [ -n "$CCUSAGE_RAW" ]; then
        # Apply formatting improvements to ccusage output
        CCUSAGE_FORMATTED=$(echo "$CCUSAGE_RAW" | sed -E '
            # Remove model information completely
            s/🤖 [^|]+ \| //g
            # Compress cost format: "$X session / $Y today" -> "$X/$Y"
            s/\$([0-9.]+) session \/ \$([0-9.]+) today/\$\1\/\$\2/g
            # Shorten time format: "4h 29m left" -> "4h29m"
            s/([0-9]+)h ([0-9]+)m left/\1h\2m/g
            # Remove redundant text
            s/ block \(/ (/g
        ')
        
        CCUSAGE=" | $CCUSAGE_FORMATTED"
    fi
fi

# Combine all parts (inspired by your Starship format)
printf "%s📁 %s%s%s%s" "$HOSTNAME_PART" "$DIR_NAME" "$GIT_INFO" "$BATTERY" "$CCUSAGE"
