#!/usr/bin/env bash
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || exit 0

brew_bin() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return
  fi

  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$candidate" ]] && printf '%s\n' "$candidate" && return
  done

  return 1
}

brew="$(brew_bin)" || { echo "Homebrew is not installed" >&2; exit 1; }

BREWFILE="${HOME}/.local/share/chezmoi/packages/macos/Brewfile"

echo "Installing Brewfile packages..."
"$brew" bundle --file "$BREWFILE"
