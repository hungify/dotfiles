if status is-interactive

set -g -x fish_greeting '👋 @hungify'

# Load node
nvm use default
clear

# Starship Prompt
starship init fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

#deno
set --export DENO_INSTALL "$HOME/.deno"
set --export PATH $DENO_INSTALL/bin $PATH

# alias
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'

alias gbs='git branch --sort=-committerdate'

end
