autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
if [[ -f "$zcompdump" ]]; then
  compinit -C -d "$zcompdump"
else
  compinit -d "$zcompdump"
fi
