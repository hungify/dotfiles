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
