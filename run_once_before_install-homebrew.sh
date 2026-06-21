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

if brew="$(brew_bin 2>/dev/null)"; then
  echo "Homebrew already installed at $brew"
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
