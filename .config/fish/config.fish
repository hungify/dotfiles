if status is-interactive
    # Commands to run in interactive sessions can go here

set -g -x fish_greeting '👋 @hungify'

starship init fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# alias
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'

alias gbs='git branch --sort=-committerdate'

end
