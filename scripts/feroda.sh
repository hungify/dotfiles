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
	GNOME_TERMINAL_PROFILE='gsettings get org.gnome.Terminal.ProfilesList default | tr -d \"'
	gsettings set org.gnome.Terminal.Legacy/profiles:/:$GNOME_TERMINAL_PROFILE/font 'Fira Code 16'
	gsettings set org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/use-system-font false
	gsettings set org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/use-theme-colors false
	gsettings set org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/cursor-shape 'underline'
	gsettings set org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/background-color 'rgb(0,43,54)'
	gsettings set org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/foreground-color 'rgb(131,148,150)'
}

function update_system {
	echo "Updating software ..."
	sudo dnf check-update

}

function install_terminal_tools {
	echo "Installing Fish shell and Starship"
	sudo dnf install fish
	echo "Switch to fish shell"
	sudo dnf install util-linux-user
	sudo chsh -s /usr/bin/fish
	curl -sS https://starship.rs/install.sh | sh
}

function install_some_software {
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
	echo "Installing Visual Studio Code"
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	sudo dnf install code
	echo "Installing Git"
	sudo dnf install git
}

function install_ibus_bamboo {
	echo "Installing ibus bamboo"
	dnf config-manager --add-repo https://download.opensuse.org/repositories/home:lamlng/Fedora_Rawhide/home:lamlng.repo
	dnf install ibus-bamboo
}

function remove_firefox {
	echo "Removing firefox ..."
	sudo dnf remove firefox.x86_64
	sudo dnf autoremove
}

function install_nvm {
	echo "Installing nvm"
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
	echo "Installing fisher"
	curl -sL https://git.io/fisher | source && fisher install jorgebucaran/nvm.fish
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



install
