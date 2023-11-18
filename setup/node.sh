#!/bin/bash

function install_lts_node {
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
}

# Install fnm
if [[ ! $(fnm --version) ]]; then
	echo "Installing fnm"
	brew install fnm
	echo "fnm installed"
else
	echo "fnm already installed"
fi
echo "Installing latest LTS version of Node.js"
install_lts_node
