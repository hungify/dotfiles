[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh

# Load env vars
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(fnm env --use-on-cd)"
eval "$(starship init zsh)"

# Load ZSH Plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pyenv
export PATH=$PATH:/Users/hungify/Library/Python/3.9/bin
