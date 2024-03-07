#!/bin/bash

# Install brew
if [[ ! $(brew --version) ]]; then
	echo "Installing brew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo "Brew installed"
else
	echo "Brew already installed, updating brew"
	brew upgrade
fi

# Tap homebrew/cask-fonts
brew tap homebrew/cask-fonts

# Install apps
xargs brew install < apps.txt


# Install bun
if [[ ! $(bun -v) ]]; then
	echo "Installing bun"
	curl -fsSL https://bun.sh/install | bash
	echo "Bun installed"
else
	bun upgrade
	echo "bun already installed"
fi


# Install rust
if [[ ! $(rustc --version) ]]; then
    echo "Installing rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    echo "Rust installed"
else
    echo "Rust already installed"
fi
