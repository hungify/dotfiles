export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
export PAGER="${PAGER:-less}"

typeset -U path PATH
typeset -a extra_path

for dir in \
  "$HOME/.lazyssh" \
  "$PYENV_ROOT/bin" \
  "$HOME/.gem/bin" \
  "$HOME/fvm/default/bin" \
  "$HOME/.antigravity/antigravity/bin" \
  "$HOME/.amp/bin"
do
  [[ -d "$dir" ]] && extra_path+=("$dir")
done

if [[ "$(uname -s)" == "Darwin" ]] && [[ -r "$XDG_CONFIG_HOME/zsh/macos.zsh" ]]; then
  source "$XDG_CONFIG_HOME/zsh/macos.zsh"
fi

if [[ "$(uname -s)" == "Linux" ]] && [[ -r "$XDG_CONFIG_HOME/zsh/linux.zsh" ]]; then
  source "$XDG_CONFIG_HOME/zsh/linux.zsh"
fi

export EDITOR="${EDITOR:-vi}"
export VISUAL="${VISUAL:-$EDITOR}"

path=(
  $extra_path
  $path
)
