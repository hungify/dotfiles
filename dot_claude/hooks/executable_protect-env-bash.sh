#!/usr/bin/env bash
# PreToolUse guard for Bash: blocks commands that read, write, or delete a real
# .env file (rm .env, cat .env, mv .env ..., > .env, etc). Templates like
# .env.example/.env.sample/.env.template are allowed through.
set -euo pipefail

input="$(cat)"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

[[ -z "$command" ]] && exit 0

if printf '%s' "$command" | grep -Eq '(^|[/[:space:]"'"'"'])\.env($|[[:space:]"'"'"'])'; then
  echo "BLOCKED: this command touches a .env file. Ask the user to run it themselves." >&2
  exit 2
fi

exit 0
