# cargo
. "$HOME/.cargo/env"

# Load env vars
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(fnm env --use-on-cd)"

# bun completions
[ -s "/Users/hungify/.bun/_bun" ] && source "/Users/hungify/.bun/_bun"

# lazyssh
FNM_PATH="/Users/hungify/.lazyssh"
if [ -d "$FNM_PATH" ]; then
	export PATH="/Users/hungify/.lazyssh:$PATH"
fi

# pnpm
export PNPM_HOME="/Users/hungify/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pyenv
export PATH="$PATH:$HOME/Library/Python/3.9/bin"

#gem
export PATH=$HOME/.gem/bin:$PATH

#Android
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools

# fvm
export PATH="$HOME/fvm/default/bin:$PATH"

# jdk
export PATH="/usr/local/opt/openjdk@17/bin:$PATH"

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"
# bun completions
[ -s "/Users/hungify/.bun/_bun" ] && source "/Users/hungify/.bun/_bun"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# Added by Antigravity
export PATH="/Users/hungify/.antigravity/antigravity/bin:$PATH"

# Amp CLI
export PATH="/Users/hungify/.amp/bin:$PATH"
