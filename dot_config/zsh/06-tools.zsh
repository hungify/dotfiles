# mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# atuin
if command -v atuin >/dev/null 2>&1; then
  [[ -t 1 ]] && eval "$(atuin init zsh)"
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
  [[ -t 1 ]] && source <(fzf --zsh)
fi

# starship
if command -v starship >/dev/null 2>&1; then
  [[ -t 1 ]] && eval "$(starship init zsh)"
fi
