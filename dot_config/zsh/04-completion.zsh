autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
# compinit silently can't persist the dump (and rebuilds from scratch every
# shell) if this directory doesn't exist yet.
[[ -d "${zcompdump:h}" ]] || mkdir -p "${zcompdump:h}"
# Regenerate the dump if it's missing or older than a day (new completions
# installed since it was last built, e.g. via brew, wouldn't be picked up
# otherwise); otherwise skip compinit's own security check for speed.
if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi

# fzf-tab replaces the default tab-completion menu with fzf; must load right
# after compinit, before other widgets wrap tab-completion.
zinit light Aloxaf/fzf-tab

# syntax-highlighting and autosuggestions are deferred with turbo mode since
# they aren't needed until the prompt is already interactive.
zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions
