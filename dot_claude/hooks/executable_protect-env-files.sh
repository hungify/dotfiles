#!/usr/bin/env bash
# PreToolUse guard for Read/Edit/Write: blocks touching real .env files.
# Templates like .env.example/.env.sample/.env.template are allowed through.
set -euo pipefail

input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

[[ -z "$file_path" ]] && exit 0

base="$(basename "$file_path")"

if [[ "$base" == .env* ]]; then
  case "$base" in
    *.example|*.sample|*.template|*.dist)
      exit 0
      ;;
    *)
      echo "BLOCKED: $file_path looks like a real .env file. Ask the user to view/edit it themselves." >&2
      exit 2
      ;;
  esac
fi

exit 0
