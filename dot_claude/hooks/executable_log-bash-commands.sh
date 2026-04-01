#!/bin/bash
set -euo pipefail

DB="$HOME/.claude/hooks/bash_commands.db"

input=$(cat)

command=$(echo "$input" | jq -r '.tool_input.command // empty')
[ -z "$command" ] && exit 0

session_id=$(echo "$input" | jq -r '.session_id // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')
description=$(echo "$input" | jq -r '.tool_input.description // empty')

sqlite3 "$DB" <<SQL
CREATE TABLE IF NOT EXISTS commands (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT DEFAULT (datetime('now')),
    session_id TEXT,
    cwd TEXT,
    command TEXT,
    description TEXT
);
INSERT INTO commands (session_id, cwd, command, description)
VALUES ('$session_id', '$cwd', '$(echo "$command" | sed "s/'/''/g")', '$(echo "$description" | sed "s/'/''/g")');
SQL

exit 0
