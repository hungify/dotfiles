# dotfiles

Personal dotfiles with one CLI, one `home/` tree, and a cross-platform bootstrap flow for macOS, Ubuntu, and Fedora.

## Layout

- `bin/dotfiles`: the only CLI you need
- `home/`: files symlinked into `$HOME`
- `packages/linux/`: distro-native package lists for Ubuntu and Fedora
- `packages/macos/`: Homebrew manifest and optional GUI casks for macOS
- `scripts/`: OS-specific helpers such as macOS defaults and SSH setup

## Quick Start

Clone the repo and run:

```bash
./bin/dotfiles bootstrap --force
```

That flow:

1. installs base system packages for the current OS
2. on macOS only: installs Homebrew if missing
3. on macOS only: installs packages from `packages/macos/Brewfile`
4. symlinks everything from `home/` into `$HOME`

If you also want optional personal macOS GUI apps:

```bash
./bin/dotfiles bootstrap --force --extras
```

## Commands

```bash
./bin/dotfiles doctor
./bin/dotfiles doctor --verbose
./bin/dotfiles list
./bin/dotfiles list --os ubuntu
./bin/dotfiles install
./bin/dotfiles link --force
./bin/dotfiles unlink
./bin/dotfiles macos
./bin/dotfiles ssh
```

## Notes

- Existing files are only replaced when you pass `--force`; replaced files are backed up under `${XDG_STATE_HOME:-~/.local/state}/dotfiles/backups/`.
- macOS uses Homebrew for shared tooling; Ubuntu and Fedora stay native to `apt` and `dnf`.
- `./bin/dotfiles list` prints the package set for the current OS; use `--os ubuntu`, `--os fedora`, `--os macos`, or `--os macos-casks` to inspect another target.
- `./bin/dotfiles doctor` also reports missing declared packages on Ubuntu and Fedora; add `--verbose` to print each declared package with `ok` or `missing`.
- `make list`, `make list OS=ubuntu`, and `make doctor-verbose` wrap the common CLI flows.
- `home/.zshenv` stays cross-platform; macOS-only shell exports and PATH additions live in `home/.config/zsh/macos.zsh`.
- `home/.config/zsh/linux.zsh` is the matching place for Linux-only shell tweaks, so platform-specific shell logic stays out of the shared base file.
- `home/.zprofile` follows Homebrew's recommended `brew shellenv` flow on macOS across `/opt/homebrew` and `/usr/local`.
- `home/.zshrc` keeps interactive setup in one file and sources local overrides from `~/.config/zsh/local.zsh` or `~/.zshrc.local` if present.
- Linux shells load `zsh-autosuggestions` and `zsh-syntax-highlighting` from distro paths under `/usr/share/...` when those packages are installed.
- `packages/macos/Brewfile` is macOS-only; `packages/macos/casks.txt` is best-effort for personal GUI apps that may fail or disappear over time.
