[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh

# Load env vars
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(fnm env --use-on-cd)"

# Load Bun CLI
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
