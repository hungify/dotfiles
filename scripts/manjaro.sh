#!/bin/bash

function initialize {
	echo "Updating pacman database..."
	sudo pacman -Syyu
	sudo pacman -S git curl
}

function install_terminal_tools {
  echo "Installing Fish shell and Starship"
  sudo pacman -S fish
	curl -sS https://starship.rs/install.sh | sh
}

function install_some_software {
	echo "Installing Visual Studio Code"
	flatpak install flathub com.visualstudio.code
	echo "Installing Skype"
	flatpak install flathub com.skype.Client
	echo "Installing Figma"
	flatpak install flathub io.github.Figma_Linux.figma_linux
	echo "Installing Brave Browser"
	flatpak install flathub com.brave.Browser
	echo "Installing Postman"
	flatpak install flathub com.getpostman.Postman
	echo "Installing Github Desktop"
	flatpak install flathub io.github.shiftey.Desktop
	echo "Installing Extension Manager"
	flatpak install flathub com.mattjakeman.ExtensionManager
}

function install_ibus_bamboo {
	echo "Installing ibus bamboo"
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/BambooEngine/ibus-bamboo/master/archlinux/install.sh)"

	echo "Setup environment"
	sudo sh -c "echo -e '\n# Ibus Bamboo\nGTK_IM_MODULE=ibus\nIbus Bamboo QT_IM_MODULE=ibus\nIbus Bamboo XMODIFIERS=@im=ibus\n' >> /etc/environment"
}

function install {
	initialize
	install_terminal_tools
	install_some_software
	install_ibus_bamboo
}

install