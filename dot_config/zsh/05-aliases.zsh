# Shell aliases
alias grep='grep --color=auto'
alias cls='clear'
alias mv='mv -iv'
alias cp='cp -riv'
alias mkdir='mkdir -vp'
alias ld='lazydocker'
alias cc='claude --permission-mode auto'
alias cx='codex --approve-for-me'
# Omit --mode: agy starts in auto mode by default when agentMode is unset (--mode=auto races auth and falls back to default)
alias ag='agy'
alias ccy='claude --permission-mode bypassPermissions'
alias cxy='codex --dangerously-bypass-approvals-and-sandbox'
alias agyy='agy --dangerously-skip-permissions'
alias hd="herdr"

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

if command -v eza >/dev/null 2>&1; then
  alias tree='eza -T'
fi

if command -v trash-put >/dev/null 2>&1; then
  alias rm='trash-put'
  alias tp='trash-put'
  alias tl='trash-list'
  alias tr='trash-restore'
fi

lg()
{
  export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

  lazygit "$@"

  if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
    cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
    rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
  fi
}
