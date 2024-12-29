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
xargs brew install <apps.txt

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

# Install fnm
if [[ ! $(fnm --version) ]]; then
	echo "Installing fnm"
	brew install fnm
	echo "fnm installed"
else
	echo "fnm already installed"
fi
echo "Installing latest LTS version of Node.js"

# Install Node
if [[ ! $(fnm ls | grep lts) ]]; then
	read -p "What version of Node.js do you want to install? (lts, or a specific version): " answer
	if [[ $answer =~ ^[nLl]ts$ ]]; then
		echo "Installing latest LTS version of Node.js"
		fnm install --lts
	else
		echo "Installing version $answer of Node.js"
		fnm install $answer
	fi
else
	echo "Latest LTS version of Node.js already installed"
fi
