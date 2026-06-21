#!/usr/bin/env bash
set -euo pipefail

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools not installed. Run: xcode-select --install"
else
  echo "Xcode Command Line Tools already installed"
fi
