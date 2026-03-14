#!/usr/bin/env bash
# Warn when an SSH command contains destructive operations targeting remote hosts

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

# Only check commands that invoke SSH
if ! echo "$COMMAND" | grep -qE '\bssh\b'; then
  exit 0
fi

# Destructive patterns to flag
DESTRUCTIVE_PATTERNS='rm -rf|DROP TABLE|DROP DATABASE|truncate|mkfs|dd if=|reboot|shutdown|poweroff|kill -9|pkill -9|format'

if echo "$COMMAND" | grep -qE "$DESTRUCTIVE_PATTERNS"; then
  echo "WARNING: This SSH command contains a potentially destructive operation. Please review carefully before proceeding." >&2
fi

exit 0
