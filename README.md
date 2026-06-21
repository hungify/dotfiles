# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). macOS only.

## Quick Start

On a fresh Mac:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:hungify/dotfiles.git
```

This will:
- Install chezmoi
- Clone this repo to `~/.local/share/chezmoi`
- Install Xcode Command Line Tools (if missing)
- Install Homebrew (if missing)
- Install Brewfile packages
- Apply macOS defaults
- Symlink all dotfiles to `$HOME`
- Install Zinit + plugins (zsh-autosuggestions, zsh-syntax-highlighting)
- Prompt for Git name, email, GitHub username, SSH key, VPS hosts

First shell launch: Zinit auto-clones plugins on first `zsh` launch. Subsequent launches use the cached version.

## Daily Usage

```bash
chezmoi update    # git pull + apply
chezmoi diff      # preview changes before applying
chezmoi managed   # list all managed files
chezmoi doctor    # diagnose issues
chezmoi edit <file>  # edit a managed file
```

## Layout

```
dotfiles/
├── .chezmoi.toml.tmpl              # Prompt data (name, email, VPS hosts)
├── .chezmoiignore                  # Files chezmoi should ignore
├── dot_config/
│   ├── ghostty/                    # Ghostty terminal + shaders
│   ├── zed/                        # Zed editor settings
│   ├── starship.toml               # Starship prompt
│   ├── lazygit/                    # Lazygit config
│   ├── inshellisense/              # Inshellisense
│   └── zsh/                        # Zsh config (modular)
│       ├── 01-zinit.zsh            # Zinit bootstrap + plugin load
│       ├── 02-options.zsh          # Zsh options
│       ├── 03-history.zsh          # History settings
│       ├── 04-completion.zsh       # Compinit + completions
│       ├── 05-aliases.zsh          # Aliases
│       ├── 06-tools.zsh            # Tool init (mise, direnv, zoxide, fzf, starship)
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
└── run_once_before_*.sh            # One-time install scripts
```

## Notes

- `private_dot_ssh/` gets `0700` permissions automatically
- `run_once_before_*` scripts run before file application (e.g., install Homebrew first)
- `.chezmoiignore` excludes node_modules, secrets, and build artifacts
- `dot_config/zsh/local.zsh` is for machine-specific overrides (not tracked in git)
- Plugins (zsh-autosuggestions, zsh-syntax-highlighting) are managed by Zinit
