#!/usr/bin/env bash
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || exit 0

# Keep Homebrew non-interactive: skip the analytics prompt, the post-install
# auto-update check, and the "ask mode" confirmation before downloads.
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ASK=1

brew_bin() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return
  fi

  [[ -x /opt/homebrew/bin/brew ]] && printf '%s\n' /opt/homebrew/bin/brew && return

  return 1
}

if brew="$(brew_bin 2>/dev/null)"; then
  echo "Homebrew already installed at $brew"
else
  echo "Installing Homebrew..."
  # If Xcode Command Line Tools are missing, this installer triggers a
  # blocking GUI dialog (softwareupdate GUI installer) that needs a manual
  # click — the bootstrap will appear to hang until it's dismissed.
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

