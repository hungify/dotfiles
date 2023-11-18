# Upgrade brew
brew upgrade

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

# Install thorium browser
brew install --cask alex313031-thorium

# Install arc browser
brew install --cask arc

# Install alt tab
brew install --cask alt-tab

# Install skype
brew install --cask skype

# Install discord
brew install --cask discord

# Install docker
brew install --cask docker

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

# Install starship
brew install starship

# Install spotify
brew install --cask spotify

# Install exa
brew install exa

# Install bun
if [[ ! $(bun --version) ]]; then
	echo "Installing bun"
	curl -fsSL https://bun.sh/install | bash
	echo "bun installed"
else
	bun upgrade
	echo "bun already installed"
fi

# Install czg
brew install czg

# Install pnpm
brew install pnpm

# Install lazygit
brew install jesseduffield/lazygit/lazygit

# Install al dente
brew install --cask aldente

# Install zsh-autosuggestions
brew install zsh-autosuggestions

# Disable quarantine
sudo xattr -rd com.apple.quarantine /Applications/Mos.app
sudo xattr -rd com.apple.quarantine /Applications/EVKey.app
sudo xattr -rd com.apple.quarantine /Applications/Thorium.app
