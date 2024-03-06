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

# Tap homebrew/cask-versions
brew tap homebrew/cask-versions

# Install firefox developer edition
brew install --cask firefox-developer-edition

# Install zed
brew install --cask zed

# Install font
brew install font-monaspace

# Install mos
brew install --cask mos

# Install vs code
brew install --cask visual-studio-code

# Install Microsoft edge
brew install --cask microsoft-edge

# Install arc browser
brew install --cask arc

# Install alt tab
brew install --cask alt-tab

# Install skype
brew install --cask skype

# Install discord
brew install --cask discord

# Install OrbStack
brew install --cask orbstack

# Install warp terminal
brew install --cask warp

# Install EVKey
brew install --cask evkey

# Install the unarchiver
brew install --cask the-unarchiver

# Install app cleaner
brew install --cask appcleaner

# Install postman
brew install --cask postman

# Install vlc
brew install --cask vlc

# Install raycast
# brew install --cask raycast

# Install rectangle
brew install --cask rectangle

# Install spotify
brew install --cask spotify

# Install bun
if [[ ! $(bun -v) ]]; then
	echo "Installing bun"
	curl -fsSL https://bun.sh/install | bash
	echo "Bun installed"
else
	bun upgrade
	echo "bun already installed"
fi

# Install pnpm
brew install pnpm

# Install lazygit
brew install jesseduffield/lazygit/lazygit

# Install aldente
brew install --cask aldente

# Install rust
if [[ ! $(rustc --version) ]]; then
    echo "Installing rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    echo "Rust installed"
else
    echo "Rust already installed"
fi
