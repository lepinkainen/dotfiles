#!/bin/bash
set -euo pipefail

DB="$HOME/.claude/hooks/bash_commands.db"

if [ ! -f "$DB" ]; then
  echo "No database found at $DB"
  exit 1
fi

echo "=== Top 20 Most Frequent Commands ==="
sqlite3 -header -column "$DB" "
  SELECT command, COUNT(*) as count
  FROM commands
  GROUP BY command
  ORDER BY count DESC
  LIMIT 20;
"

echo ""
echo "=== Permission Candidates (by command prefix) ==="
sqlite3 -header -column "$DB" "
  SELECT
    CASE
      WHEN command LIKE 'git %' THEN 'git ' || substr(command, 5, instr(substr(command, 5), ' ') - 1)
      WHEN command LIKE 'gh %' THEN 'gh ' || substr(command, 4, instr(substr(command, 4), ' ') - 1)
      WHEN command LIKE 'docker %' THEN 'docker ' || substr(command, 8, instr(substr(command, 8), ' ') - 1)
      WHEN command LIKE 'npm %' THEN 'npm ' || substr(command, 5, instr(substr(command, 5), ' ') - 1)
      WHEN command LIKE 'dotnet %' THEN 'dotnet ' || substr(command, 8, instr(substr(command, 8), ' ') - 1)
      ELSE substr(command, 1, instr(command || ' ', ' ') - 1)
    END as prefix,
    COUNT(*) as count
  FROM commands
  GROUP BY prefix
  ORDER BY count DESC
  LIMIT 20;
"

echo ""
echo "=== Last 10 Commands ==="
sqlite3 -header -column "$DB" "
  SELECT timestamp, command, cwd
  FROM commands
  ORDER BY id DESC
  LIMIT 10;
"
