# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). macOS only.

## Quick Start

On a fresh Mac:

```bash
sh -c '
  xcode-select -p &>/dev/null || {
    echo "Installing Xcode Command Line Tools (headless)..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l 2>/dev/null | grep "\*.*Command Line" | tail -n 1 | sed "s/^[^C]* //")
    sudo softwareupdate -i "$PROD" --verbose
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  }
' && sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source "$HOME/dotfiles" https://github.com/hungify/dotfiles.git
```

You do not need to clone the repository separately: `chezmoi init --apply`
downloads it from the HTTPS URL above and applies it in the same run.

`chezmoi init` itself shells out to the system `git` to clone this repo — and on a brand-new Mac, `git` is just an `xcode-select` stub that pops a blocking GUI installer and exits non-zero instead of waiting, so the clone fails before any script in this repo gets a chance to run. The first part of the command above installs Command Line Tools non-interactively via `softwareupdate` (no GUI dialog) so real `git` exists before chezmoi ever calls it — it'll ask for your `sudo` password once, then run unattended.

A brand-new Mac has no SSH key registered with GitHub yet, so the initial clone uses HTTPS. Adding a key later does not change that remote URL. To switch this checkout to SSH after registering the key, run `git -C "$HOME/dotfiles" remote set-url origin git@github.com:hungify/dotfiles.git`; the default profile then supplies its SSH key for Git operations.

On first initialization, chezmoi asks for the personal Git name, email, GitHub
username, and SSH key filename. These required values are saved in the local
chezmoi config before dotfiles are applied; later `chezmoi init` runs reuse them.

This will:

- Install Xcode Command Line Tools headlessly (if missing)
- Clone this repo to `~/dotfiles` (also baked into `sourceDir` in `.chezmoi.toml.tmpl`, so later `chezmoi apply`/`update` keep using it without needing `--source` again)
- Install Homebrew (if missing)
- Install Rosetta 2 (if missing, Apple Silicon only)
- Install Brewfile packages
- Install optional GUI apps from `casks.txt` (one by one, a bad name won't break the rest)
- Apply macOS defaults
- Symlink all dotfiles to `$HOME`; the local chezmoi config contains Git account profiles
- Install Zinit + plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab)

First shell launch: Zinit auto-clones plugins on first `zsh` launch. Subsequent launches use the cached version.

The `softwareupdate -l` product-name parsing above can break on macOS version changes. If the headless install fails, fall back to `xcode-select --install` and click through the GUI dialog manually, then re-run the `chezmoi init --apply --source "$HOME/dotfiles"` command by itself.

`run_onchange_before_01/02/03` re-run automatically whenever `packages/macos/Brewfile`, `packages/macos/casks.txt`, or `dot_config/mise/config.toml` change (including on a plain `chezmoi apply`/`chezmoi update` after editing them) — not just once per machine.

## Daily Usage

```bash
chezmoi update    # git pull + apply
chezmoi diff      # preview changes before applying
chezmoi managed   # list all managed files
chezmoi doctor    # diagnose issues
chezmoi edit <file>  # edit a managed file
```

## AI CLI status lines & defaults

Unified 2-row Dark Tokyo Night status line and safe OS-sandbox defaults across **Antigravity CLI (`agy`)**, **Codex CLI (`codex`)**, and **Claude Code (`claude`)**:

```text
Gemini 4 Hydrogen (Medium) | auto | ~/dotfiles | main* | +12 −3 | PR #42 (open) | 1 subagent
Context: ▰▰▰▱▱▱▱▱▱▱▱▱ 220K/1M (22%) | 5h: 72% (1h30m) | wk: 65% (1d9h)
```

- **Row 1:**
  - *AI & safety (left):* Model (with reasoning effort), active mode / permission / tier badge (`auto`, `auto-approve`, `fast`, `turbo`, `bypass`).
  - *Workspace & Git (middle):* Shortened CWD (`depth=2`), Git branch (`*`, `REBASE`/`MERGING`, `⇡a ⇣b`), worktree (`wt:`), diff stats (`+a −r`), and clickable PR hyperlink (`PR #<num> (<state>)`, state colored: open/approved green, changes_requested yellow, closed red, merged purple).
  - *Dynamic state (right):* Running subagents/tasks, named agent, and Vim mode (kept at the far right so `CWD` and `branch` never shift horizontally).
- **Row 2:** 12-cell geometric `Context` bar (`▰`/`▱`), used `5h` and `wk` (weekly) (plus `argon` when active in `agy`) quota % (same direction as context: higher = worse) with inline reset timers shown when `>= 60%` used.
- **Defaults:** OS terminal sandbox enabled across all three CLIs (`enableTerminalSandbox: true` in `agy`, `workspace-write` + `Approve for me` in `codex`, `sandbox.enabled: true` + `permissions.deny` + `.env` hooks in `claude`). Chezmoi `run_onchange_after_*` scripts upsert shared defaults without overwriting machine-local state (`trustedWorkspaces`, `projects`, active model).

## Layout

```txt
dotfiles/
├── .chezmoi.toml.tmpl              # Required first-run prompts for the personal Git profile
├── .chezmoiignore                  # Files chezmoi should ignore
├── dot_claude/
│   ├── settings.json               # Claude Code: statusLine + permission guardrails
│   └── hooks/                      # PreToolUse hooks (deny rules alone don't reliably block .env access)
│       ├── executable_protect-env-files.sh  # blocks Read/Edit/Write on real .env files
│       └── executable_protect-env-bash.sh   # blocks Bash commands touching a .env file
├── dot_config/
│   ├── antigravity/executable_statusline.sh  # Antigravity CLI 2-row status line
│   ├── claude/executable_statusline.sh       # Claude Code 2-row status line
│   ├── codex/statusline.py                   # Codex CLI MCP status line provider
│   ├── ghostty/                              # Ghostty terminal + shaders
│   ├── zed/                        # Zed editor settings
│   ├── starship.toml               # Starship prompt
│   ├── lazygit/                    # Lazygit config
│   ├── inshellisense/              # Inshellisense
│   ├── mise/                       # mise tool versions (e.g. node)
│   └── zsh/                        # Zsh config (modular)
│       ├── 01-zinit.zsh            # Zinit bootstrap + plugin load
│       ├── 02-options.zsh          # Zsh options
│       ├── 03-history.zsh          # History settings
│       ├── 04-completion.zsh       # Compinit + completions
│       ├── 05-aliases.zsh          # Aliases
│       ├── 06-tools.zsh            # Tool init (mise, zoxide, atuin, fzf, starship, inshellisense)
│       ├── macos.zsh               # macOS PATH + env vars
│       └── local.zsh               # Machine-specific (not tracked)
├── dot_gitconfig.tmpl              # Git config + per-directory account includes
├── .chezmoitemplates/git-account  # Shared per-account Git config template
├── run_onchange_after_15-git-accounts.sh.tmpl # Generates local account configs
├── dot_library/                    # macOS keybindings
├── dot_zshenv                      # XDG, PATH, Homebrew shellenv
├── dot_zshrc                       # Entry point → sources zsh/ files
├── packages/macos/
│   ├── Brewfile                    # Brew packages
│   └── casks.txt                   # Optional casks
├── run_once_before_00-install-homebrew.sh              # One-time: Homebrew + Rosetta 2
├── run_onchange_before_{01,02,03}-*.sh.tmpl            # Re-run when their source file's content changes
└── run_onchange_after_{04,05}-*.sh.tmpl                # Upsert Codex & Antigravity CLI defaults
```

## Notes

- Bootstrap scripts run before file application, in filename order: `00-install-homebrew.sh` (runs once) → `01-install-brew-packages.sh` (re-runs on `Brewfile` changes) → `02-install-system-packages.sh` (re-runs on `dot_config/mise/config.toml` changes) → `03-install-casks.sh` (re-runs on `casks.txt` changes)
- `~/.ssh/config` and SSH private keys are not tracked (by design) — restore/create them manually on a new machine
- `dot_claude/settings.json` denies obviously destructive commands (`rm -rf`, force push, `git reset --hard`, branch deletion, disk/docker wipes, `sudo rm -rf`) even in bypass-permission mode — deny rules and hooks are not skipped by `skipDangerousModePermissionPrompt`/bypass mode, only the interactive "ask" prompts are
- `.env` files are protected by a hook, not a deny rule — `permissions.deny` for `Read(**/.env*)` is known to be unreliable (see [anthropics/claude-code#24846](https://github.com/anthropics/claude-code/issues/24846)); `dot_claude/hooks/` blocks Read/Edit/Write/Bash access to real `.env` files (templates like `.env.example` are allowed)
- `.chezmoiignore` excludes node_modules, secrets, and build artifacts
- `dot_config/zsh/local.zsh` is for machine-specific overrides (not tracked in git)
- Plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab) are managed by Zinit

## Multiple GitHub accounts

All accounts, including personal, use the same profile pattern. Chezmoi
generates `~/.config/git/accounts/<account>.gitconfig` from the account tables
in the local `~/.config/chezmoi/chezmoi.toml`. The `default` account is used
outside the configured directories; each account's `dir` selects repositories
that should use it. Each profile can pin its own SSH key.

On first init, the config template requires the personal name, email, GitHub
username, and SSH key filename. It stores them under the `personal` profile in
the local config. Existing flat personal settings are migrated automatically;
to change the identity later, edit its local table:

```toml
[data.git]
default = "personal"

[data.git.accounts.personal]
name = "Your Name"
email = "you@example.com"
github_user = "your-personal-user"
ssh_key = "personal"
```

Create a separate key for each GitHub account and add the matching public key to
that account in GitHub → Settings → SSH and GPG keys:

```sh
ssh-keygen -t ed25519 -C "work@example.com" -f ~/.ssh/id_ed25519_work
```

Add another account to `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.git.accounts.work]
dir = "~/work/"                 # repositories under this directory use this profile
name = "Your Name"
email = "work@example.com"
github_user = "your-work-user"
ssh_key = "id_ed25519_work"    # private key filename in ~/.ssh
```

Then create the directory and apply the dotfiles:

```sh
mkdir -p ~/work
chezmoi apply
```

Repositories outside configured account directories use the profile named by
`[data.git].default`. For any repository, confirm the selected identity and key
from inside its directory:

```sh
git config --show-origin --get user.email
git config --get core.sshCommand
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_ed25519_work -T git@github.com
```

For another account, create another key and add another
`[data.git.accounts.<name>]` section with a distinct `dir`. Run `chezmoi apply`
after changing account data to regenerate the Git config files.
