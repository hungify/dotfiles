[[ -o interactive ]] || return

setopt auto_cd interactive_comments no_beep
setopt extended_history hist_ignore_all_dups hist_ignore_space hist_save_no_dups inc_append_history share_history

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000

mkdir -p "${HISTFILE:h}" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
if [[ -f "$zcompdump" ]]; then
  compinit -C -d "$zcompdump"
else
  compinit -d "$zcompdump"
fi

alias grep='grep --color=auto'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias mv='mv -iv'
alias cp='cp -riv'
alias mkdir='mkdir -vp'
alias top='top -o vsize'
alias p='pnpm'

trash() {
  mkdir -p "$HOME/.trash" || return 1
  command mv "$@" "$HOME/.trash"
}

c() {
  if command -v code >/dev/null 2>&1; then
    code "${1:-.}"
  elif command -v zed >/dev/null 2>&1; then
    zed "${1:-.}"
  else
    return 127
  fi
}

o() {
  if command -v open >/dev/null 2>&1; then
    open "${1:-.}"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "${1:-.}"
  else
    return 127
  fi
}

_run_npm_script() {
  [[ -f package.json ]] || return 127
  npm run "$1" -- "${@:2}"
}

dev() {
  _run_npm_script dev "$@"
}

build() {
  _run_npm_script build "$@"
}

test() {
  _run_npm_script test "$@"
}

coverage() {
  _run_npm_script coverage "$@"
}

start() {
  _run_npm_script start "$@"
}

serve() {
  _run_npm_script serve "$@"
}

install() {
  [[ -f package.json ]] || return 127

  if [[ -f yarn.lock ]]; then
    yarn install "$@"
  elif [[ -f pnpm-lock.yaml ]]; then
    pnpm install "$@"
  else
    npm install "$@"
  fi
}

run() {
  [[ -f Cargo.toml ]] || return 127
  cargo run "$@"
}

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
  [[ -t 1 ]] && eval "$(atuin init zsh)"
fi

if command -v fzf >/dev/null 2>&1; then
  [[ -t 1 ]] && source <(fzf --zsh)
fi

[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

brew_prefix="${HOMEBREW_PREFIX:-}"
if [[ -z "$brew_prefix" ]]; then
  for candidate in /opt/homebrew /usr/local; do
    if [[ -d "$candidate/share" ]]; then
      brew_prefix="$candidate"
      break
    fi
  done
fi

if [[ -r "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  [[ -t 1 ]] && source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  [[ -t 1 ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if command -v starship >/dev/null 2>&1; then
  [[ -t 1 ]] && eval "$(starship init zsh)"
fi

[[ -r "$XDG_CONFIG_HOME/zsh/local.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/local.zsh"
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

if [[ -r "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  [[ -t 1 ]] && source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  [[ -t 1 ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
