#!/bin/bash

function config_system_settings {
	echo "Setup Keyboard shortcuts"
	gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>t']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys control-center "['<Super>i']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>w']"


	gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
	gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>z']"

	gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Shift><Super>s']"
	gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Control><Super>x']"

	# extension
	gsettings set org.gnome.shell.extensions.cliboard-indicator toggle-menu "['<Super>v']"

	gsettings set org.gnome.desktop.interface cursor-size 32

	#terminal
	echo "Setup Terminal"
	bash
	GNOME_TERMINAL_PROFILE=`gsettings get org.gnome.Terminal.ProfilesList default | tr -d \'`
	gsettings set org.gnome.Terminal.Legacy/profiles:/:$GNOME_TERMINAL_PROFILE/font 'Fira Code 16'
	gsettings set org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/use-system-font false
	gsettings set org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/use-theme-colors false
	gsettings set org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/cursor-shape 'underline'
	gsettings set org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/background-color 'rgb(0,43,54)'
	gsettings set org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/foreground-color 'rgb(131,148,150)'
}

function update_system {
	echo "Updating pacman database..."
	sudo pacman -Syyu
	sudo pacman -S --needed git base-devel curl
}

function install_terminal_tools {
  echo "Installing Fish shell and Starship"
  yes Y | sudo pacman -S fish
	echo "Switch to fish shell"
	chsh -s /usr/bin/fish
	curl -sS https://starship.rs/install.sh | sh
}

function install_some_software {
	echo "Installing Skype"
	yes Y | flatpak install flathub com.skype.Client
	echo "Installing Figma"
	yes Y | flatpak install flathub io.github.Figma_Linux.figma_linux
	echo "Installing Brave Browser"
	yes Y | flatpak install flathub com.brave.Browser
	echo "Installing Postman"
	yes Y | flatpak install flathub com.getpostman.Postman
	echo "Installing Github Desktop"
	yes Y | flatpak install flathub io.github.shiftey.Desktop
	echo "Installing Extension Manager"
	yes Y | flatpak install flathub com.mattjakeman.ExtensionManager
	echo "Installing Visual Studio Code"
	sh -c "$(git clone https://aur.archlinux.org/visual-studio-code-bin.git)"
	echo "Make package ..."
	cd visual-studio-code-bin && makepkg -si
	echo "Remove folder ..."
	cd .. && rm -rf visual-studio-code-bin
}

function install_ibus_bamboo {
	echo "Installing ibus bamboo"
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/BambooEngine/ibus-bamboo/master/archlinux/install.sh)"

	echo "Setup environment"
	yes Y | sudo sh -c "echo -e '\n# Ibus Bamboo\nGTK_IM_MODULE=ibus\nIbus Bamboo QT_IM_MODULE=ibus\nIbus Bamboo XMODIFIERS=@im=ibus\n' >> /etc/environment"
}

function remove_firefox {
	sudo base -c "pacman -Rcns firefox"
}

function install_nvm {
	echo "Installing nvm"
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
	echo "Installing fisher"
	curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
	echo "Installing bass plugin"
	fisher install edc/bass
}

function install {
	update_system
	install_terminal_tools
	install_some_software
	install_ibus_bamboo
	remove_firefox
	config_system_settings
}



install_nvm
