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
' && sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/hungify/dotfiles.git
```

`chezmoi init` itself shells out to the system `git` to clone this repo — and on a brand-new Mac, `git` is just an `xcode-select` stub that pops a blocking GUI installer and exits non-zero instead of waiting, so the clone fails before any script in this repo gets a chance to run. The first part of the command above installs Command Line Tools non-interactively via `softwareupdate` (no GUI dialog) so real `git` exists before chezmoi ever calls it — it'll ask for your `sudo` password once, then run unattended.

A brand-new Mac has no SSH key registered with GitHub yet, so the initial clone must use HTTPS, not `git@github.com:...`. Once `private_dot_ssh/` is restored and a key is added to GitHub, git will use SSH for this repo's own remote via `dot_gitconfig`'s `sshCommand` (day-to-day pulls/pushes), but the bootstrap clone itself needs HTTPS.

This will:

- Install Xcode Command Line Tools headlessly (if missing)
- Clone this repo to `~/.local/share/chezmoi`
- Install Homebrew (if missing)
- Install Rosetta 2 (if missing, Apple Silicon only)
- Install Brewfile packages
- Install optional GUI apps from `casks.txt` (one by one, a bad name won't break the rest)
- Apply macOS defaults
- Symlink all dotfiles to `$HOME`, using the Git name/email/GitHub username/SSH key/VPS hosts hardcoded in `.chezmoi.toml.tmpl` (edit that file directly if you fork this for someone else — it does not prompt)
- Install Zinit + plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab)

First shell launch: Zinit auto-clones plugins on first `zsh` launch. Subsequent launches use the cached version.

The `softwareupdate -l` product-name parsing above can break on macOS version changes. If the headless install fails, fall back to `xcode-select --install` and click through the GUI dialog manually, then re-run the `chezmoi init --apply` command by itself.

`run_onchange_before_01/02/03` re-run automatically whenever `packages/macos/Brewfile`, `packages/macos/casks.txt`, or `dot_config/mise/config.toml` change (including on a plain `chezmoi apply`/`chezmoi update` after editing them) — not just once per machine.

## Daily Usage

```bash
chezmoi update    # git pull + apply
chezmoi diff      # preview changes before applying
chezmoi managed   # list all managed files
chezmoi doctor    # diagnose issues
chezmoi edit <file>  # edit a managed file
```

## Layout

```txt
dotfiles/
├── .chezmoi.toml.tmpl              # Prompt data (name, email, VPS hosts)
├── .chezmoiignore                  # Files chezmoi should ignore
├── dot_claude/
│   ├── settings.json               # Claude Code: statusLine + permission guardrails
│   └── hooks/                      # PreToolUse hooks (deny rules alone don't reliably block .env access)
│       ├── executable_protect-env-files.sh  # blocks Read/Edit/Write on real .env files
│       └── executable_protect-env-bash.sh   # blocks Bash commands touching a .env file
├── dot_config/
│   ├── ghostty/                    # Ghostty terminal + shaders
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
├── dot_gitconfig                   # Git config
├── dot_gitconfig-personal.tmpl     # Git identity (from .chezmoi data)
├── dot_library/                    # macOS keybindings
├── dot_zshenv                      # XDG, PATH, Homebrew shellenv
├── dot_zshrc                       # Entry point → sources zsh/ files
├── private_dot_ssh/                # SSH config (0700 perms)
│   └── config.tmpl                 # SSH hosts (from .chezmoi data)
├── packages/macos/
│   ├── Brewfile                    # Brew packages
│   └── casks.txt                   # Optional casks
├── run_once_before_00-install-homebrew.sh              # One-time: Homebrew + Rosetta 2
└── run_onchange_before_{01,02,03}-*.sh.tmpl            # Re-run when their source file's content changes
```

## Notes

- `private_dot_ssh/` gets `0700` permissions automatically
- Bootstrap scripts run before file application, in filename order: `00-install-homebrew.sh` (runs once) → `01-install-brew-packages.sh` (re-runs on `Brewfile` changes) → `02-install-system-packages.sh` (re-runs on `dot_config/mise/config.toml` changes) → `03-install-casks.sh` (re-runs on `casks.txt` changes)
- SSH private keys are not tracked (by design) — restore them to `~/.ssh/` manually on a new machine before relying on `private_dot_ssh/config.tmpl`'s hosts
- `dot_claude/settings.json` denies obviously destructive commands (`rm -rf`, force push, `git reset --hard`, branch deletion, disk/docker wipes, `sudo rm -rf`) even in bypass-permission mode — deny rules and hooks are not skipped by `skipDangerousModePermissionPrompt`/bypass mode, only the interactive "ask" prompts are
- `.env` files are protected by a hook, not a deny rule — `permissions.deny` for `Read(**/.env*)` is known to be unreliable (see [anthropics/claude-code#24846](https://github.com/anthropics/claude-code/issues/24846)); `dot_claude/hooks/` blocks Read/Edit/Write/Bash access to real `.env` files (templates like `.env.example` are allowed)
- `.chezmoiignore` excludes node_modules, secrets, and build artifacts
- `dot_config/zsh/local.zsh` is for machine-specific overrides (not tracked in git)
- Plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab) are managed by Zinit
