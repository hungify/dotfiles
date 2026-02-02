[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh

eval "$(/opt/homebrew/bin/brew shellenv)"

fpath=(/opt/homebrew/share/zsh-completions $fpath)

autoload -Uz compinit
compinit

source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.plugin.zsh

zstyle ':completion:*' menu select
